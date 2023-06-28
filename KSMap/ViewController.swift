//
//  ViewController.swift
//  TestMap
//
//  Created by Kathusan on 18/11/22.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    let controller = MapViewController()
    
    @IBOutlet var backButton: UIButton!
    @IBOutlet var mapView: UIView!
    
    var currentState: ExpandAndColapse = .collapse {
        didSet {
            UIView.animate(withDuration: 0.05, animations: {
                self.expandOrColapse(self.currentState)
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.mapView.addGestureRecognizer(tap)
        controller.view.frame  = mapView.bounds
        self.mapView.insertSubview(controller.view, belowSubview: backButton)
        addChild(controller)
        controller.didMove(toParent: self)
    }
    
    private func expandOrColapse(_ currentState: ExpandAndColapse) {
        switch currentState {
        case .expand:
            self.backButton.isHidden = false
            controller.removeFromParent()
            controller.view.frame  = view.bounds
            self.view.insertSubview(controller.view, belowSubview: backButton)
            addChild(controller)
            controller.didMove(toParent: self)
            
        case .collapse:
            backButton.isHidden = true
            controller.removeFromParent()
            controller.view.frame = mapView.bounds
            mapView.addSubview(controller.view)
            addChild(controller)
            controller.didMove(toParent: self)
        }
        controller.currentState = currentState
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        currentState  = .expand
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        currentState = .collapse
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        let mapView = MapViewController()
        mapView.modalPresentationStyle = .fullScreen
        mapView.modalTransitionStyle =  .crossDissolve
        self.present(mapView, animated: true)
    }
    
}

enum ExpandAndColapse {
    case expand
    case collapse
}



