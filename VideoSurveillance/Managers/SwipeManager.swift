//
//  SwipeManager.swift
//  VideoSurveillance
//
//  Created by Yury on 02/10/2023.
//

import UIKit
import RealmSwift

class SwipeManager {
    
    // MARK: - Properties
    
    static let shared = SwipeManager()
    
    // MARK: Init
    
    // Закрытый инициализатор, чтобы предотвратить создание новых экземпляров класса
    private init() {}
    
}

// MARK: - Methods

extension SwipeManager {
    
    // Add to favorites cams for trailing swipe for Cams
    func addToFavoritesCams(at indexPath: IndexPath, using camDataModel: Cameras, for tableView: UITableView) -> UIContextualAction {
        var localCamDataModel = camDataModel
        let isFavorite = localCamDataModel.data.cameras[indexPath.section].favorites
        let favorites = UIContextualAction(style: .normal, title: "") { _, _, completion in
            do {
                let realm = try Realm()
                try realm.write {
                    localCamDataModel.data.cameras[indexPath.section].favorites = !isFavorite
                    let cameraRealm = realm.object(ofType: CameraRealm.self, forPrimaryKey: localCamDataModel.data.cameras[indexPath.section].id)
                    cameraRealm?.favorites = localCamDataModel.data.cameras[indexPath.section].favorites
                }
                
                if let customCamsCell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell {
                    customCamsCell.favoriteStar.isHidden = !localCamDataModel.data.cameras[indexPath.section].favorites
                }
                completion(true)
            } catch let error {
                Logger.logRealmError(error)
            }
        }
        
        favorites.image = UIImage(named: "star")
        favorites.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        return favorites
    }
    
    // Adding edit mode for the cell with doors section for trailing swipe
    func editMode(at indexPath: IndexPath, using viewController: MainViewController) -> UIContextualAction {
        let editMode = UIContextualAction(style: .normal, title: "") { _, _, completion in
            viewController.selectedIndexPath = indexPath
            viewController.performSegue(withIdentifier: "toEditSegue", sender: nil)
            completion(true)
        }
        
        editMode.image = UIImage(named: "edit")
        editMode.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        return editMode
    }
    
    // Add to favorites doors for trailing swipe for Doors
    func addToFavoritesDoors(at indexPath: IndexPath, using doorDataModel: Doors, for tableView: UITableView) -> UIContextualAction {
        var localDoorDataModel = doorDataModel
        let isFavorite = localDoorDataModel.data[indexPath.section].favorites
        let favorites = UIContextualAction(style: .normal, title: "") { _, _, completion in
            do {
                let realm = try Realm()
                try realm.write {
                    localDoorDataModel.data[indexPath.section].favorites = !isFavorite
                    let doorRealm = realm.object(ofType: DoorRealm.self, forPrimaryKey: localDoorDataModel.data[indexPath.section].id)
                    doorRealm?.favorites = localDoorDataModel.data[indexPath.section].favorites
                }
                
                if let customDoorsCell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell {
                    customDoorsCell.favoriteStar.isHidden = !localDoorDataModel.data[indexPath.section].favorites
                }
                completion(true)
            } catch let error {
                Logger.logRealmError(error)
            }
        }
        
        favorites.image = UIImage(named: "star")
        favorites.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        return favorites
    }
    
}
