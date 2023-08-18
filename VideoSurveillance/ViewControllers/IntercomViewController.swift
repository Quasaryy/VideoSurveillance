//
//  DomophoneViewController.swift
//  VideoSurveillance
//
//  Created by Yury on 17/08/2023.
//

import UIKit

class IntercomViewController: UIViewController {

    // MARK: - IB Outlets
    @IBOutlet weak var intercomImage: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var viewWithKey: UIView!
    @IBOutlet weak var doorOpenLabel: UILabel!
    
    // MARK: - Properties
    var idOfDoor: Int!
    private var hideOrNot = true
    var openOrCloseDoor = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add shadow and borders for the bottom views
        configureShadowAndBorders(for: bottomView)
        viewWithKey.layer.cornerRadius = 12
        print(openOrCloseDoor)
        
        // Checking current status door lock
        if openOrCloseDoor == false {
            doorOpenLabel.text = "Дверь открыта - (Закрыть)"
        } else {
            doorOpenLabel.text = "Дверь закрыта - (Открыть)"
        }
    }
    
    
    // Open or close door
    @IBAction func keyButtonTapped(_ sender: UIButton) {
        if openOrCloseDoor == true {
            doorOpenLabel.text = "Дверь открыта - (Закрыть)"
            openOrCloseDoor = !openOrCloseDoor
        } else {
            doorOpenLabel.text = "Дверь закрыта - (Открыть)"
            openOrCloseDoor = !openOrCloseDoor
        }
    }
    
    @IBAction func hideButtonTapped(_ sender: UIButton) {
        intercomImage.isHidden = hideOrNot ? true : false
        hideOrNot = !hideOrNot
    }
    
    @IBAction func upArrowButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func settingsButtonTapper(_ sender: UIButton) {
        
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

}

// MARK: - Private Methods
extension IntercomViewController {
    // Add shadow and borders for the bottom view
    private func configureShadowAndBorders(for: UIView) {
        self.bottomView.layer.masksToBounds = false
        self.bottomView.layer.shadowColor = UIColor.black.cgColor
        self.bottomView.layer.shadowOffset = CGSize(width: 0, height: -2)
        self.bottomView.layer.shadowRadius = 90
        self.bottomView.layer.shadowOpacity = 0.1
        
        self.bottomView.layer.borderWidth = 0.3
        self.bottomView.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.1).cgColor
    }
    
}
