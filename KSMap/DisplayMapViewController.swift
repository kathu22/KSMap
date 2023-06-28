//
//  DisplayMapViewController.swift
//  TestMap
//
//  Created by Vagus Air Book on 10/01/23.
//

import UIKit

class DisplayMapViewController: UIViewController {
    
    @IBOutlet var backButton: UIButton!
    
    
    let controller = MapViewController()
    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(controller)
        controller.view.frame = self.view.bounds
       // self.view.addSubview((controller.view)!)
        backButton.setTitle("Back", for: .normal)
        self.view.insertSubview((controller.view)!, belowSubview: backButton)

        controller.didMove(toParent: self)
    }

    @IBAction func backButtonActio(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
}
