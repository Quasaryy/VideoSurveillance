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
        if let sourceViewController = segue.source as? EditViewController {
            let id = sourceViewController.doorId
            let textField = sourceViewController.editDoorNameTextField.text
            
            if let doors = realm.object(ofType: DoorRealm.self, forPrimaryKey: id) {
                try? realm.write {
                    doors.name = textField ?? ""
                }
                
                let doorName = realm.objects(DoorRealm.self).compactMap { $0.name }
                
                if let indexPath = selectedIndexPath, doorName.indices.contains(indexPath.section) {
                    doorDataModel.data[indexPath.section].name = doorName[indexPath.section]
                    DispatchQueue.main.async {
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                } else {
                    Logger.log("error")
                }
            }
        } else if let sourceViewController = segue.source as? IntercomeViewController {
            let id = sourceViewController.idOfDoor
            let statusLock = sourceViewController.openOrCloseDoor
            
            if let doors = realm.object(ofType: DoorRealm.self, forPrimaryKey: id) {
                try? realm.write {
                    doors.lockIcon = statusLock
                }
                
                let lockIconStatus = realm.objects(DoorRealm.self).compactMap { $0.lockIcon }
                
                if let indexPath = selectedIndexPath, lockIconStatus.indices.contains(indexPath.section) {
                    doorDataModel.data[indexPath.section].lockIcon = lockIconStatus[indexPath.section]
                    Logger.logLockStatus(lockIconStatus[indexPath.section])
                    
                    if let customCell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell {
                        customCell.unLock.isHidden = doorDataModel.data[indexPath.section].lockIcon ?? true
                        customCell.lockOn.isHidden = !customCell.unLock.isHidden
                    }
                } else {
                    Logger.log("error")
                }
            }
        }
    }
    
}
