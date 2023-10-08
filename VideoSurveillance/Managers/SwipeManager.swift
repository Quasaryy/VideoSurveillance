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
    func addToFavoritesCams(at indexPath: IndexPath, using camDataModel: Cameras, for tableView: UITableView, completion: @escaping (Cameras?) -> Void) -> UIContextualAction {
        let favorites = UIContextualAction(style: .normal, title: "") { _, _, actionCompletion in
            var updatedModel = camDataModel
            do {
                let realm = try Realm()
                
                let cameraId = updatedModel.data.cameras[indexPath.section].id
                if let camera = realm.object(ofType: CameraRealm.self, forPrimaryKey: cameraId) {
                    let isFavorite = camera.favorites
                    try realm.write {
                        camera.favorites = !isFavorite
                    }
                    
                    updatedModel.data.cameras[indexPath.section].favorites = camera.favorites
                    completion(updatedModel)
                    actionCompletion(true)
                } else {
                    completion(nil)
                    actionCompletion(false)
                }

            } catch let error {
                Logger.logRealmError(error)
                completion(nil)
                actionCompletion(false)
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
    func addToFavoritesDoors(at indexPath: IndexPath, using doorDataModel: Doors, for tableView: UITableView, completion: @escaping (Doors?) -> Void) -> UIContextualAction {
        let favorites = UIContextualAction(style: .normal, title: "") { _, _, actionCompletion in
            var updatedModel = doorDataModel
            do {
                let realm = try Realm()
                
                let doorId = updatedModel.data[indexPath.section].id
                if let door = realm.object(ofType: DoorRealm.self, forPrimaryKey: doorId) {
                    let isFavorite = door.favorites
                    try realm.write {
                        door.favorites = !isFavorite
                    }
                    
                    updatedModel.data[indexPath.section].favorites = door.favorites
                    completion(updatedModel)
                    actionCompletion(true)
                } else {
                    completion(nil)
                    actionCompletion(false)
                }

            } catch let error {
                Logger.logRealmError(error)
                completion(nil)
                actionCompletion(false)
            }
        }

        favorites.image = UIImage(named: "star")
        favorites.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        return favorites
    }
    
}
