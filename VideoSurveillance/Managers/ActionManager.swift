//
//  ActionManager.swift
//  VideoSurveillance
//
//  Created by Yury on 02/10/2023.
//

import UIKit

class ActionManager {
    
    // MARK: - Properties
    
    static let shared = ActionManager()
    
    // MARK: - Init
    
    // Закрытый инициализатор, чтобы предотвратить создание новых экземпляров класса
    private init() {}
    
}

// MARK: - Methods

extension ActionManager {
    
    // MARK: Intercome
    
    func toggleDoorState(openOrCloseDoor: inout Bool, doorOpenLabel: UILabel) {
        openOrCloseDoor.toggle()
        doorOpenLabel.text = openOrCloseDoor ? "Дверь закрыта - (Открыть)" : "Дверь открыта - (Закрыть)"
    }
    
    func toggleIntercomImageVisibility(hideOrNot: inout Bool, intercomImage: UIImageView) {
        intercomImage.isHidden = hideOrNot
        hideOrNot.toggle()
    }
    
    func dismissViewController(controller: UIViewController) {
        controller.dismiss(animated: true)
    }
    
    // MARK: Main controller
    
    func handleSegmentChange(for sender: UISegmentedControl, constraint: NSLayoutConstraint, roomNameLabel: UILabel, tableView: UITableView) {
        sender.changeUnderlinePosition()
        
        guard let state = ActiveSegment(rawValue: sender.selectedSegmentIndex) else { return }
        
        switch state {
            case .cameras:
                updateUI(for: constraint,
                         roomNameLabel: roomNameLabel,
                         tableView: tableView,
                         constant: 25.0,
                         isLabelHidden: false)
            case .doors:
                updateUI(for: constraint,
                         roomNameLabel: roomNameLabel,
                         tableView: tableView,
                         constant: 5.0,
                         isLabelHidden: true)
        }
    }
    
    private func updateUI(for constraint: NSLayoutConstraint, roomNameLabel: UILabel, tableView: UITableView, constant: CGFloat, isLabelHidden: Bool) {
        constraint.constant = constant
        roomNameLabel.isHidden = isLabelHidden
        tableView.reloadData()
    }
    
}
