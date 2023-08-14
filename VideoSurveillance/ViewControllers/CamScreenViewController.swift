//
//  ViewController.swift
//  VideoSurveillance
//
//  Created by Yury on 11/08/2023.
//

import UIKit
import RealmSwift

class CamsScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IB Outlets
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private let realm = try! Realm() // Creating Realm instance
    private var newDataModel = Cameras.shared // Model for remote data
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding delegates and data source for tableView
        tableView.dataSource = self
        tableView.delegate = self
        
        // Adding underline for segmentedControl
        segmentedControl.addUnderlineForSelectedSegment()
        
        // Try loading data from Realm on startup
        loadAndDisplayDataFromRealm()
        
    }
    
    // MARK: - IB Actions
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        segmentedControl.changeUnderlinePosition()
        
        // Go to door section by SegmentedControl
        if segmentedControl.selectedSegmentIndex == 1 {
            performSegue(withIdentifier: "toTheDoors", sender: nil)
        } else {
            return
        }
        
    }
    
    
    // To setup closing animation to false
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTheDoors" {
            if let destinationViewController = segue.destination as? DoorsScreenViewController {
                destinationViewController.modalTransitionStyle = .crossDissolve
            }
        }
    }
    
    
    @IBAction func unwindSegueToCamers(segue: UIStoryboardSegue) {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.changeUnderlinePosition()
        
    }
    
    // MARK: - TableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return newDataModel.data.cameras.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "camsCell", for: indexPath) as! CamsTableViewCell
        
        // Configure the cell
        cell.configCamsCellVideoImage(model: newDataModel, indexPath: indexPath, tableView: tableView)
        cell.camLabel.text = newDataModel.data.cameras[indexPath.section].name
        cell.favoriteStar.isHidden = !newDataModel.data.cameras[indexPath.section].favorites
        cell.cameraRecorded.isHidden = !newDataModel.data.cameras[indexPath.section].rec
        
        return cell
    }
    
    // MARK: - TableView Data Source
    // Adding trailing swipe
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let addTofavorites = addToFavorites(at: indexPath)
        return UISwipeActionsConfiguration(actions: [addTofavorites])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Checking rooms name by Id camera
        let idOfCamera = newDataModel.data.cameras[indexPath.section].id
        
        switch idOfCamera {
        case 1:
            roomNameLabel.text = newDataModel.data.cameras[indexPath.section].room
        case 2:
            roomNameLabel.text = newDataModel.data.cameras[indexPath.section].room
        case 3:
            roomNameLabel.text = newDataModel.data.cameras[indexPath.section].room
        case 6:
            roomNameLabel.text = newDataModel.data.cameras[indexPath.section].room
        default:
            return
        }
    }
    
    
}


// MARK: - Private Methods
extension CamsScreenViewController {
    
    // Add to favorites cams for trailing swipe
    private func addToFavorites(at indexPath: IndexPath) -> UIContextualAction {
        let isFavorite = newDataModel.data.cameras[indexPath.section].favorites
        let favorites = UIContextualAction(style: .normal, title: "") { _, _, completion in
            self.newDataModel.data.cameras[indexPath.section].favorites = isFavorite ? false : true
            if let customCamsCell = self.tableView.cellForRow(at: indexPath) as? CamsTableViewCell {
                customCamsCell.favoriteStar.isHidden = !self.newDataModel.data.cameras[indexPath.section].favorites
            }
            completion(true)
        }
        
        favorites.image = UIImage(named: "star")
        favorites.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        return favorites
    }
    
    // MARK: Network request
    private func getDataFromRemoteServer() {
        guard let url = URL(string: "https://cars.cprogroup.ru/api/rubetek/cameras/") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.alert(title: "Something wrong", message: error.localizedDescription)
                }
                return
            }
            
            if let response = response {
                print(response)
            }
            
            guard let remoteData = data else { return }
            do {
                let RealmDataModel = try JSONDecoder().decode(Cameras.self, from: remoteData)
                
                // Saving data to Realm
                do {
                    let realm = try Realm()
                    print("Realm is located at:", realm.configuration.fileURL!)
                    try realm.write {
                        realm.add(RealmDataModel.data.cameras.map { cameraData in
                            return CameraRealm(value: [
                                "id": cameraData.id,
                                "name": cameraData.name,
                                "snapshot": cameraData.snapshot,
                                "room": cameraData.room ?? "",
                                "favorites": cameraData.favorites,
                                "rec": cameraData.rec
                            ] as [String : Any])
                        }, update: .modified)
                    }
                } catch let error {
                    print("Realm error: \(error)")
                    DispatchQueue.main.async {
                        self.alert(title: "Realm Error", message: "An error occurred while saving data.")
                    }
                }
                
                DispatchQueue.main.async {
                    self.newDataModel = RealmDataModel // Update data model
                    self.tableView.reloadData()
                }
            } catch let error {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.alert(title: "Remote data decoding error", message: "We are working on fixing the bug, please try again later.")
                }
            }
        }.resume()
    }
    
    // MARK: Alert controller
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let buttonOK = UIAlertAction(title: "OK", style: .default)
        alert.addAction(buttonOK)
        present(alert, animated: true)
    }
    
    // MARK: Realm section
    // The method of loading data from Realm or from the server
        private func loadAndDisplayDataFromRealm() {
            let cameras = realm.objects(CameraRealm.self) // Loading data from Realm

            if cameras.isEmpty {
                // If there is no data in Realm, make a request to the server
                getDataFromRemoteServer()
            } else {
                // If the data is in the Realm display it
                newDataModel.data.cameras = cameras.map { cameraRealm in
                    return Camera(
                        name: cameraRealm.name,
                        snapshot: cameraRealm.snapshot,
                        room: cameraRealm.room,
                        id: cameraRealm.id,
                        favorites: cameraRealm.favorites,
                        rec: cameraRealm.rec
                    )
                }
                tableView.reloadData()
            }
        }

        // Method to update data via pull-to-refresh
        @objc private func refreshData(_ sender: UIRefreshControl) {
            getDataFromRemoteServer()
            sender.endRefreshing()
        }
    
}

