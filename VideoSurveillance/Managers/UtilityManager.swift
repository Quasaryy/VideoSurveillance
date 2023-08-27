//
//  UtilityManager.swift
//  VideoSurveillance
//
//  Created by Yury on 27/08/2023.
//

import UIKit

class UtilityManager {
    
    // MARK: - Properties
    static let shared = UtilityManager()
    
    // MARK: - Init
    private init() {}

}

// MARK: - Method
extension UtilityManager {
    
    // Add shadow and borders for the bottom view
    func configureShadowAndBorders(for view: UIView) {
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 90
        view.layer.shadowOpacity = 0.1
        
        view.layer.borderWidth = 0.3
        view.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.1).cgColor
    }
    
    // Checking current status door lock
    func updateDoorsStatus(_ openOrCloseDoor: Bool, doorOpenLabel: UILabel) {
            if openOrCloseDoor == false {
                doorOpenLabel.text = "Дверь открыта - (Закрыть)"
            } else {
                doorOpenLabel.text = "Дверь закрыта - (Открыть)"
            }
        }
}
