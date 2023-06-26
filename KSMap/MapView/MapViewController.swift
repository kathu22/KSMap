//
//  MapViewController.swift
//  TestMap
//
//  Created by Kathusan on 18/11/22.
//

import UIKit
import MapKit
import CoreLocation

/// Link : https://www.gpxgenerator.com - for free gpx file generator
class MapViewController: UIViewController {
    
 //  static let shared = MapViewController()
    //MARK: - Outlets
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var miles: UILabel!
    @IBOutlet var hours: UILabel!
    @IBOutlet var hoursStackView: UIStackView!
    @IBOutlet var etaView: UIView!
    
    //MARK: - Variables
    var didFinishedLoading: Bool = false // To view the entire map location after finish loading only once
    var userPolyLine: MKPolyline? // Used to identify overlay path is from user's current location
    var travelledPath: MKPolyline? // Used to identify overlay path travelled by user
    let locationManager = CLLocationManager()
    var oldLocationNew : CLLocation?
    
    var currentState: ExpandAndColapse = .collapse {
        didSet {
            if currentState == .collapse {
               
            }else {
                
            }
        }
    }
    
    //create two dummy locations
    let loc1 = Locations(annotationType: .pickup, title: "Location 1", subtitle: "First pickup location", coordinate: CLLocationCoordinate2D.init(latitude: 37.33259552, longitude: -122.03031802))
    let loc2 = Locations(annotationType: .pickup, title: "Location 2", subtitle: "Second pickup location", coordinate: CLLocationCoordinate2D.init(latitude: 38.33259552, longitude: -110.04031802))
    let loc3 = Locations(annotationType: .pickup, title: "Location 3", subtitle: "Third pickup location", coordinate: CLLocationCoordinate2D.init(latitude: 36.33259552, longitude: -115.05031802))
    let loc4 = Locations(annotationType: .drop, title: "Location 4", subtitle: "First drop location", coordinate: CLLocationCoordinate2D.init(latitude: 39.33259552, longitude: -118.06031802))
    let loc5 = Locations(annotationType: .drop, title: "Location 5", subtitle: "Second pickup location", coordinate: CLLocationCoordinate2D.init(latitude: 34.33259552, longitude: -119.07031802))
    let loc6 = Locations(annotationType: .drop, title: "Location 6", subtitle: "Third pickup location", coordinate: CLLocationCoordinate2D.init(latitude: 40.33259552, longitude: -124.08031802))
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = .mutedStandard
        
        let locations = [loc1, loc2, loc3, loc4, loc5, loc6]
        addAnnotation(coordinates: locations)
        //find route
        for i in 1..<locations.count {
            showRouteOnMap(pickupCoordinate: locations[i - 1] , destinationCoordinate: locations[i])
        }

        locationManager.delegate = self
        
        // location updates when the user is using your app
        locationManager.requestWhenInUseAuthorization()
        
        // Start updating location
        locationManager.startUpdatingLocation()
        mapView.userTrackingMode = .none
        mapView.showsCompass = true
        
        locationManager.distanceFilter = 1 // distance changes you want to be informed about (in meters)
        locationManager.activityType = .automotiveNavigation // .automotiveNavigation will stop the updates when the device is not moving
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Make sure to stop updating location when your
        // app no longer needs location updates
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        etaView.layer.cornerRadius = etaView.layer.frame.height / 4
    }
    
    private func addAnnotation(coordinates: [Locations]) {
        for coordinate in coordinates {
            let location = coordinate
            mapView.addAnnotation(location)
        }
        
    }
    
    func showRouteOnMap(pickupCoordinate: Locations, destinationCoordinate: Locations, isUserLocation: Bool = false) {
        if isUserLocation {
            self.mapView.removeOverlay(userPolyLine ?? MKPolyline())
        }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: pickupCoordinate.coordinate, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate.coordinate, addressDictionary: nil))
        //request.requestsAlternateRoutes = true
        request.transportType = .automobile
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            if error != nil {
                //If not able to get root between two location then draw straight line between two point
                let polyLine = CustomPolyline(coordinates: [pickupCoordinate.coordinate, destinationCoordinate.coordinate], count: 2)
                polyLine.type = destinationCoordinate.annotationType
                if isUserLocation {
                    userPolyLine = polyLine
                }
                
                mapView.addOverlay(polyLine)
            }
            guard let unwrappedResponse = response else { return }
            
            //for getting just one route
            if let route = unwrappedResponse.routes.first {
                // //show on map
                let routePolyline = route.polyline
                if isUserLocation {
                    userPolyLine = routePolyline
                }
                
                self.mapView.addOverlay(route.polyline)
                //set the map area to show the route
                //self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 80.0, left: 20.0, bottom: 100.0, right: 20.0), animated: true)
            }
            
            //if you want to show multiple routes then you can get all routes in a loop in the following statement
            //for route in unwrappedResponse.routes { }
        }
    }
    
    func getETA(pickupCoordinate: Locations, destinationCoordinate: Locations) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: pickupCoordinate.coordinate, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate.coordinate, addressDictionary: nil))
        //request.requestsAlternateRoutes = true
        request.transportType = .automobile
        let directions = MKDirections(request: request)
        directions.calculateETA { [unowned self] response, error in
            if error != nil { return }
            guard let unwrappedResponse = response else { return }
            let expectedTravelTime = unwrappedResponse.expectedArrivalDate
            self.hours.text = expectedTravelTime.toString(dateFormat: "MMM dd, hh:mm a")
            let distance = unwrappedResponse.distance
            self.miles.text = "\(meterToMiles(Int(distance)))"
        }
        
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func meterToMiles(_ meter: Int) -> Int {
        return meter / 1609
    }
    
    @IBAction func userLocationButtonAction(_ sender: Any) {
        mapView.userTrackingMode = .follow
    }
    
    @IBAction func showAnotationsButtonAction(_ sender: Any) {
        mapView.showAnnotations(self.mapView.annotations, animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    
    //To change the marker for user location
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let annotation = annotation as? Locations else { return nil }
            
            let pin = mapView.view(for: annotation) as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
            pin.animatesWhenAdded = true
            switch annotation.annotationType {
                case .user:
                    pin.markerTintColor = .green
                case .pickup:
                    pin.markerTintColor = .blue
                case .drop:
                    pin.markerTintColor = .red
            }
            pin.glyphImage = UIImage(named: "pin")
            pin.selectedGlyphImage = UIImage(named: "truck")
            pin.animatesWhenAdded = true
            
            return pin
        }
    
    //To Animate Location markers
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        var i = -1;
        for view in views {
            i += 1;
            if view.annotation is MKUserLocation { continue }
            let point:MKMapPoint  =  MKMapPoint(view.annotation!.coordinate)
            if (!self.mapView.visibleMapRect.contains(point)) { continue }
            let endFrame:CGRect = view.frame
            view.frame = CGRect(origin: CGPoint(x: view.frame.origin.x,y :view.frame.origin.y - self.view.frame.size.height), size: CGSize(width: view.frame.size.width, height: view.frame.size.height))
            let delay = 0.03 * Double(i)
            UIView.animate(withDuration: 1.0, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations:{() in
                view.frame = endFrame
            }, completion:{(Bool) in
                UIView.animate(withDuration: 0.05, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations:{() in
                    view.transform = CGAffineTransform(scaleX: 1.0, y: 0.6)
                }, completion: {(Bool) in
                    UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseInOut, animations:{() in
                        view.transform = CGAffineTransform.identity
                    }, completion: nil)
                })
            })
        }
    }
    
    //this delegate function is for displaying the route overlay and styling it
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        if let overlay = overlay as? CustomPolyline {
            switch overlay.type {
                case .user:
                    renderer.strokeColor = UIColor.gray
                    renderer.lineWidth = 3.0
                case.drop:
                    renderer.strokeColor = UIColor.cyan
                    renderer.lineWidth = 3.0
                case .pickup:
                    renderer.strokeColor = UIColor.magenta
                    renderer.lineWidth = 3.0
                case .none:
                    break
            }
        } else if overlay as? MKPolyline  == userPolyLine {
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 3.0
        } else if overlay as? MKPolyline == travelledPath {
            renderer.strokeColor = UIColor.magenta
            renderer.lineWidth = 8.0
        } else {
            renderer.strokeColor = UIColor.red
            renderer.lineWidth = 3.0
        }
        return renderer
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        if !didFinishedLoading && fullyRendered {
            //1: Show all annotation on the map view
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            didFinishedLoading = true
        }
    }
    
}

class Locations: NSObject, MKAnnotation {
    var annotationType: AnnotationType
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    init(annotationType: AnnotationType, title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.annotationType = annotationType
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}

class CustomPolyline: MKPolyline {
    var type: AnnotationType?
}

enum AnnotationType {
    case user
    case pickup
    case drop
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            
           // print("lat: \(location.coordinate.latitude), long: \(location.coordinate.longitude)")
           // getETA(pickupCoordinate: Locations(annotationType: .user, title: "", subtitle: "", coordinate: location.coordinate), destinationCoordinate: loc1)
            
            guard let oldCoordinates = oldLocationNew?.coordinate else {
                showRouteOnMap(pickupCoordinate: Locations(annotationType: .user, title: "", subtitle: "", coordinate: location.coordinate) , destinationCoordinate: loc1, isUserLocation: true)
                oldLocationNew = location
                return
            }
            
            let newCoordinates = location.coordinate
            let area = [oldCoordinates, newCoordinates]
            let customPolyLine = CustomPolyline(coordinates: area, count: area.count)
            customPolyLine.type = .user
            travelledPath = customPolyLine
            mapView.addOverlay(customPolyLine)
            oldLocationNew = location
            
        }
    }
    
}


extension Date {
    
    func toString(dateFormat: String, timezone: TimeZone? = nil) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = timezone != nil ? timezone : TimeZone.ReferenceType.system
        dateFormatter.dateFormat = dateFormat
        return (dateFormatter.string(from: self))
    }
    
}

extension String {
    
    func toDate(with dateFormatter: DateFormatter) -> Date? {
        return dateFormatter.date(from: self)
    }
    
}
