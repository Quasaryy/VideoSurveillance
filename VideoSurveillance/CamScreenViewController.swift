//
//  ViewController.swift
//  VideoSurveillance
//
//  Created by Yury on 11/08/2023.
//

import UIKit

class CamScreenViewController: UIViewController {
    
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl.addUnderlineForSelectedSegment()
        
    }


    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        segmentedControl.changeUnderlinePosition()
    }
}



