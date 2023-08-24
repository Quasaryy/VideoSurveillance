//
//  Networkmanager.swift
//  VideoSurveillance
//
//  Created by Yury on 24/08/2023.
//

import Foundation
import RealmSwift
import UIKit

class NetworkManager {
    
    // MARK: - Properties
    static let shared = NetworkManager()
    
    // MARK: - Init
    private init() {}
    
}

// MARK: - Methods
extension NetworkManager {
    
    func getDoorsDataFromRemoteServerIfNeeded(tableView: UITableView, completion: @escaping (Doors) -> Void) {
        
        // Checking if there is data in the realm
        if let doorsDataInRealm = DataManagerForRealm.shared.getDoorRealms(), doorsDataInRealm.isEmpty {
            
            // If the data is not in Realm, we load it from the server
            guard let url = URL(string: "https://cars.cprogroup.ru/api/rubetek/doors/") else { return }
            URLSession.shared.dataTask(with: url) { data, response, error in
                
                if let error = error {
                    Logger.logErrorDescription(error)
                    return
                }
                
                if let response = response {
                    Logger.logResponse(response)
                }
                
                guard let remoteData = data else { return }
                
                do {
                    let dataModel = try JSONDecoder().decode(Doors.self, from: remoteData)
                    
                    // MARK: Saving data to Realm for Doors
                    DataManagerForRealm.shared.saveDoorsToRealm(dataModel.data)
                    
                    DispatchQueue.main.async {
                        let doorsModel = Doors(success: true, data: dataModel.data)
                        completion(doorsModel) // Passing an existing model through a closure
                        tableView.reloadData()
                    }
                } catch let error {
                    Logger.logErrorDescription(error)
                }
            }.resume()
            // MARK: Loading data from Realm for Cameras if data existing
        } else {
            DispatchQueue.main.async {
                let loadedData: [Datum] = DataManagerForRealm.shared.loadFromRealm(DoorRealm.self)
                let doorsModel = Doors(success: true, data: loadedData)
                completion(doorsModel) // Passing an existing model through a closure
                tableView.reloadData()
            }
        }
    }
    
    
    func getCamerasDataFromRemoteServerIfNeeded(tableView: UITableView, completion: @escaping (Cameras) -> Void) {
        
        // Checking if there is data in the realm
        if let camsDataInRealm = DataManagerForRealm.shared.getCamsRealms(), camsDataInRealm.isEmpty {
            
            // If the data is not in Realm, we load it from the server
            guard let url = URL(string: "https://cars.cprogroup.ru/api/rubetek/cameras/") else { return }
            URLSession.shared.dataTask(with: url) { data, response, error in
                
                if let error = error {
                    Logger.logErrorDescription(error)
                    return
                }
                
                if let response = response {
                    Logger.logResponse(response)
                }
                
                guard let remoteData = data else { return }
                
                do {
                    let dataModel = try JSONDecoder().decode(Cameras.self, from: remoteData)
                    
                    // MARK: Saving data to Realm for Doors if data existing
                    DataManagerForRealm.shared.saveCamerasToRealm(dataModel.data.cameras)
                    
                    DispatchQueue.main.async {
                        let camsModel = Cameras(success: true, data: DataClass(room: [], cameras: dataModel.data.cameras))
                        completion(camsModel) // Passing an existing model through a closure
                        tableView.reloadData()
                    }
                } catch let error {
                    Logger.logErrorDescription(error)
                }
            }.resume()
            // MARK: Loading data from Realm from Cameras if data existing
        } else {
            DispatchQueue.main.async {
                let loadedData: [Camera] = DataManagerForRealm.shared.loadFromRealm(CameraRealm.self)
                let camsModel = Cameras(success: true, data: DataClass(room: [], cameras: loadedData))
                completion(camsModel) // Passing an existing model through a closure
                tableView.reloadData()
            }
        }
    }
}
