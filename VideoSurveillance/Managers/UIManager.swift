//
//  UIManager.swift
//  VideoSurveillance
//
//  Created by Yury on 02/10/2023.
//

import UIKit

class UIManager {
    
    // MARK: - Properties
    
    static let shared = UIManager()
    
    // MARK: - Init
    
    // Закрытый инициализатор, чтобы предотвратить создание новых экземпляров класса
    private init() {}
    
}

// MARK: - Methods

extension UIManager {
    
    // MARK: Intercome screen
    
    func setupUIForIntercome(bottomView: UIView, viewWithKey: UIView, openOrCloseDoor: Bool, doorOpenLabel: UILabel) {
        // Add shadow and borders for the bottom views
        UtilityManager.shared.configureShadowAndBorders(for: bottomView)
        
        if let label = viewWithKey as? UILabel {
            label.layer.cornerRadius = 12
        }
        
        Logger.logLockStatus(openOrCloseDoor)
        
        // Checking current status door lock
        UtilityManager.shared.updateDoorsStatus(openOrCloseDoor: openOrCloseDoor, doorOpenLabel: doorOpenLabel)
    }
    
    // MARK: Main screen
    
    func setupUIForMainScreen(tableView: UITableView, segmentedControl: UISegmentedControl, refreshControl: UIRefreshControl, roomNameLabel: UILabel, mainController: MainViewController) {
        
        // Adding delegates and data source for tableView
        tableView.dataSource = mainController
        tableView.delegate = mainController
        
        // Checking Realm location
        Logger.logRealmLocation(mainController.realm)
        
        // Adding underline for segmentedControl
        segmentedControl.addUnderlineForSelectedSegment()
        
        // Try loading data from Realm on startup
        NetworkManager.shared.getDoorsDataFromRemoteServerIfNeeded(tableView: tableView) { doorsModel in
            mainController.doorDataModel = doorsModel
        }
        NetworkManager.shared.getCamerasDataFromRemoteServerIfNeeded(tableView: tableView) { camsModel in
            mainController.camDataModel = camsModel
        }
        
        // Adding refresh control for TableView
        tableView.refreshControl = refreshControl
        
        // Configure Refresh Control
        refreshControl.addTarget(mainController, action: #selector(mainController.refreshData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor(red: 63/255, green: 192/255, blue: 216/255, alpha: 1.0)
        refreshControl.attributedTitle = NSAttributedString(string: "Updating data from Realm")
        
        // Loading room name
        roomNameLabel.text = mainController.camDataModel.data.cameras.first?.roomNameLabel ?? "Название комнаты"
    }
    
    // MARK: Edit screen
    
    func setupUIForEditScreen(editDoorNameTextField: UITextField, saveButton: UIButton, editController: EditViewController) {
        // Background color main screen
        editController.view.backgroundColor = .systemGray6
        
        // Call method to update the state of the save button
        let textFieldText = editDoorNameTextField.text ?? ""
        saveButton.isEnabled = !textFieldText.isEmpty
    }
    
    // MARK: Custom cell
    
    func configureShadowAndBordersForCell(cell: UITableViewCell) {
        cell.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 3)
        cell.layer.shadowRadius = 3
        cell.layer.shadowOpacity = 0.5
        
        cell.layer.borderWidth = 0.3
        cell.layer.borderColor = UIColor(red: 219/255, green: 219/255, blue: 219/255, alpha: 1).cgColor
    }
    
}
