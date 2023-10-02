//
//  NavigationManager.swift
//  VideoSurveillance
//
//  Created by Yury on 02/10/2023.
//

import UIKit
import RealmSwift

class NavigationManager {
    
    // MARK: - Properties
    
    static let shared = NavigationManager()
    
    // MARK: - Init
    
    // Закрытый инициализатор, чтобы предотвратить создание новых экземпляров класса
    private init() {}
    
}

// MARK: - Methods

extension NavigationManager {
    
    // MARK: Prepare
    
    func prepare(for segue: UIStoryboardSegue, withDataModel doorDataModel: Doors?, andSelectedIndexPath selectedIndexPath: IndexPath?) {
        guard let identifier = segue.identifier else {
            return
        }
        
        if identifier == "toEditSegue", let destinationViewController = segue.destination as? EditViewController {
            let id = doorDataModel?.data[selectedIndexPath?.section ?? 0].id
            destinationViewController.doorId = id
        } else if identifier == "toIntercome", let destinationViewController = segue.destination as? IntercomeViewController {
            let id = doorDataModel?.data[selectedIndexPath?.section ?? 0].id
            destinationViewController.idOfDoor = id
            destinationViewController.openOrCloseDoor = doorDataModel?.data[selectedIndexPath?.section ?? 0].lockIcon ?? true
        }
    }
    
    // MARK: Unwind
    
    func unwindSegueLogic(segue: UIStoryboardSegue, doorDataModel: inout Doors, tableView: UITableView, realm: Realm, selectedIndexPath: IndexPath?) {
        var localDoorDataModel = doorDataModel
        if let sourceViewController = segue.source as? EditViewController {
            
            let id = sourceViewController.doorId
            let textField = sourceViewController.editDoorNameTextField.text
            
            let doors = realm.object(ofType: DoorRealm.self, forPrimaryKey: id)
            DataManagerForRealm.shared.saveObjectsToRealm(doors) {
                doors?.name = textField ?? ""
            }
            
            let doorName = DataManagerForRealm.shared.loadFromRealm(DoorRealm.self).compactMap { (datum: Datum) in
                return datum.name
            }
            
            if let indexPath = selectedIndexPath, doorName.indices.contains(indexPath.section) {
                let selectedDoorName = doorName[indexPath.section]
                localDoorDataModel.data[indexPath.section].name = selectedDoorName
                DispatchQueue.main.async {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                doorDataModel = localDoorDataModel
            } else {
                Logger.log("error")
            }
            
        } else if let sourceViewController = segue.source as? IntercomeViewController {
            
            let id = sourceViewController.idOfDoor
            let statusLock = sourceViewController.openOrCloseDoor
            
            if let doors = realm.object(ofType: DoorRealm.self, forPrimaryKey: id) {
                DataManagerForRealm.shared.saveObjectsToRealm(doors) {
                    doors.lockIcon = statusLock
                }
            }
            
            let lockIconStatus = DataManagerForRealm.shared.loadFromRealm(DoorRealm.self).compactMap { (datum: Datum) in
                return datum.lockIcon
            }
            
            if let indexPath = selectedIndexPath, lockIconStatus.indices.contains(indexPath.section) {
                let lockStatus = lockIconStatus[indexPath.section]
                doorDataModel.data[indexPath.section].lockIcon = lockStatus
                Logger.logLockStatus(lockStatus)
                
                if let customCell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell {
                    if doorDataModel.data[indexPath.section].lockIcon ?? true {
                        customCell.unLock.isHidden = true
                        customCell.lockOn.isHidden = false
                    } else {
                        if !(doorDataModel.data[indexPath.section].lockIcon ?? false) {
                            customCell.unLock.isHidden = false
                            customCell.lockOn.isHidden = true
                        }
                    }
                }
            } else {
                Logger.log("error")
            }
        }
    }
    
}
