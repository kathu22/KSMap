//
//  CustomAnnotationView.swift
//  TestMap
//
//  Created by Kathusan on 13/12/22.
//

import Foundation
import MapKit

class CustomAnnotationView: MKMarkerAnnotationView {
    ///user below code in view did load to display custom annotation view
    // mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)

    override var annotation: MKAnnotation? {
        didSet { configure(for: annotation) }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        glyphImage = Self.glyphImage
        markerTintColor = #colorLiteral(red: 0.005868499167, green: 0.5166643262, blue: 0.9889912009, alpha: 1)
        
        configure(for: annotation)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(for annotation: MKAnnotation?) {
        displayPriority = .required
        
        // if doing clustering, also add
        // clusteringIdentifier = ...
    }
    
    
    static let glyphImage: UIImage = {
        let rect = CGRect(origin: .zero, size: CGSize(width: 40, height: 40))
        return UIGraphicsImageRenderer(bounds: rect).image { _ in
            let radius: CGFloat = 11
            let offset: CGFloat = 7
            let insetY: CGFloat = 5
            let center = CGPoint(x: rect.midX, y: rect.maxY - radius - insetY)
            let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: .pi, clockwise: true)
            path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY + insetY), controlPoint: CGPoint(x: rect.midX - radius, y: center.y - offset))
            path.addQuadCurve(to: CGPoint(x: rect.midX + radius, y: center.y), controlPoint: CGPoint(x: rect.midX + radius, y: center.y - offset))
            path.close()
            UIColor.white.setFill()
            path.fill()
        }
    }()
    

    

}
