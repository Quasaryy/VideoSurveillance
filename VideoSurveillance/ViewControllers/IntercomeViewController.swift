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
        
        // Add shadow and borders for the bottom views
        UtilityManager.shared.configureShadowAndBorders(for: self.bottomView)

        viewWithKey.layer.cornerRadius = 12
        Logger.logLockStatus(openOrCloseDoor)
        
        // Checking current status door lock
        UtilityManager.shared.updateDoorsStatus(openOrCloseDoor, doorOpenLabel: doorOpenLabel)
    }
    
    // MARK: - IB Actions
    
    // Open or close door
    @IBAction func keyButtonTapped(_ sender: UIButton) {
        openOrCloseDoor.toggle()
        doorOpenLabel.text = openOrCloseDoor ? "Дверь закрыта - (Открыть)" : "Дверь открыта - (Закрыть)"
    }
    
    @IBAction func hideButtonTapped(_ sender: UIButton) {
        intercomImage.isHidden = hideOrNot
        hideOrNot.toggle()
    }
    
    // Идет переход по сгвею при тапе
    @IBAction func upArrowButtonTapped(_ sender: UIButton) {
    }
    
    // Идет переход по сгвею при тапе
    @IBAction func settingsButtonTapper(_ sender: UIButton) {
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

}
