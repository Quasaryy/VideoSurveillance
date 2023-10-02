//
//  DomophoneViewController.swift
//  VideoSurveillance
//
//  Created by Yury on 17/08/2023.
//

import UIKit

class IntercomeViewController: UIViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var intercomImage: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var viewWithKey: UIView!
    @IBOutlet weak var doorOpenLabel: UILabel!
    
    // MARK: - Properties
    
    var idOfDoor: Int?
    private var hideOrNot = true
    var openOrCloseDoor = false
    
    // MARK: - Properties
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Settup UI
        UIManager.shared.setupUIForIntercome(bottomView: bottomView, viewWithKey: viewWithKey, openOrCloseDoor: openOrCloseDoor, doorOpenLabel: doorOpenLabel)
    }
    
    // MARK: - IB Actions
    
    // Open or close door
    @IBAction func keyButtonTapped(_ sender: UIButton) {
        ActionManager.shared.toggleDoorState(openOrCloseDoor: &openOrCloseDoor, doorOpenLabel: doorOpenLabel)
    }
    
    @IBAction func hideButtonTapped(_ sender: UIButton) {
        ActionManager.shared.toggleIntercomImageVisibility(hideOrNot: &hideOrNot, intercomImage: intercomImage)
    }
    
    // Идет переход по сгвею при тапе
    @IBAction func upArrowButtonTapped(_ sender: UIButton) {
    }
    
    // Идет переход по сгвею при тапе
    @IBAction func settingsButtonTapper(_ sender: UIButton) {
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        ActionManager.shared.dismissViewController(controller: self)
    }
    
}
