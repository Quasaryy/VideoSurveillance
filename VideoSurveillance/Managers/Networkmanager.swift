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
    
    // Закрытый инициализатор, чтобы предотвратить создание новых экземпляров класса
    private init() {}
    
}

// MARK: - Methods
extension NetworkManager {
    
    
    // MARK: Doors section
    
    func getDoorsDataFromRemoteServerIfNeeded(tableView: UITableView, completion: @escaping (Doors) -> Void) {
        if let doorsDataInRealm = DataManagerForRealm.shared.getDoorRealms(), doorsDataInRealm.isEmpty {
            fetchDataFromRemoteServer(tableView: tableView, completion: completion)
        } else {
            loadDataFromRealm(tableView: tableView, completion: completion)
        }
    }

    private func fetchDataFromRemoteServer(tableView: UITableView, completion: @escaping (Doors) -> Void) {
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
                DispatchQueue.main.async {
                    self.saveAndReloadData(dataModel: dataModel, tableView: tableView, completion: completion)
                }
            } catch let error {
                Logger.logErrorDescription(error)
            }
        }.resume()
    }

    private func saveAndReloadData(dataModel: Doors, tableView: UITableView, completion: @escaping (Doors) -> Void) {
        DataManagerForRealm.shared.saveDoorsToRealm(dataModel.data)
        let doorsModel = Doors(success: true, data: dataModel.data)
        completion(doorsModel)
        tableView.reloadData()
    }

    private func loadDataFromRealm(tableView: UITableView, completion: @escaping (Doors) -> Void) {
        DispatchQueue.main.async {
            let loadedData: [Datum] = DataManagerForRealm.shared.loadFromRealm(DoorRealm.self)
            let doorsModel = Doors(success: true, data: loadedData)
            completion(doorsModel)
            tableView.reloadData()
        }
    }

    // MARK: Cameras section
    
    func getCamerasDataFromRemoteServerIfNeeded(tableView: UITableView, completion: @escaping (Cameras) -> Void) {
        if let camsDataInRealm = DataManagerForRealm.shared.getCamsRealms(), camsDataInRealm.isEmpty {
            fetchCamerasFromRemoteServer(tableView: tableView, completion: completion)
        } else {
            loadCamerasFromRealm(tableView: tableView, completion: completion)
        }
    }

    private func fetchCamerasFromRemoteServer(tableView: UITableView, completion: @escaping (Cameras) -> Void) {
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
                DispatchQueue.main.async {
                    self.saveAndReloadCamerasData(dataModel: dataModel, tableView: tableView, completion: completion)
                }
            } catch let error {
                Logger.logErrorDescription(error)
            }
        }.resume()
    }

    private func saveAndReloadCamerasData(dataModel: Cameras, tableView: UITableView, completion: @escaping (Cameras) -> Void) {
        DataManagerForRealm.shared.saveCamerasToRealm(dataModel.data.cameras)
        let camsModel = Cameras(success: true, data: DataClass(room: [], cameras: dataModel.data.cameras))
        completion(camsModel)
        tableView.reloadData()
    }

    private func loadCamerasFromRealm(tableView: UITableView, completion: @escaping (Cameras) -> Void) {
        DispatchQueue.main.async {
            let loadedData: [Camera] = DataManagerForRealm.shared.loadFromRealm(CameraRealm.self)
            let camsModel = Cameras(success: true, data: DataClass(room: [], cameras: loadedData))
            completion(camsModel)
            tableView.reloadData()
        }
    }
    
}
