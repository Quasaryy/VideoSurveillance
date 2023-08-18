//
//  ViewController.swift
//  VideoSurveillance
//
//  Created by Yury on 11/08/2023.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IB Outlets
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewConstraintTop: NSLayoutConstraint!
    
    // MARK: - Properties
    private var camDataModel = Cameras.shared // Model for remote data
    private var doorDataModel = Doors.shared // Model for remote data
    private let refreshControl = UIRefreshControl()
    private var selectedIndexPath: IndexPath?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Checking Realm location
        let realm = try! Realm()
        print("Realm is located at:", realm.configuration.fileURL!)
        
        // Adding delegates and data source for tableView
        tableView.dataSource = self
        tableView.delegate = self
        
        // Adding underline for segmentedControl
        segmentedControl.addUnderlineForSelectedSegment()
        
        // Try loading data from Realm on startup
        loadAndDisplayDataFromRealmCams()
        loadAndDisplayDataFromRealmDoors()
        
        // Loading room name
        
        // Adding refresh control for TableView
        tableView.refreshControl = refreshControl
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor(red:0.25, green:0.75, blue:0.85, alpha:1.0)
        refreshControl.attributedTitle = NSAttributedString(string: "Updating data from Realm")
        
        // Loading room name
        roomNameLabel.text = camDataModel.data.cameras.first?.roomNameLabel ?? "Название комнаты"
    }
    
    // MARK: - IB Actions
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        sender.changeUnderlinePosition()
        
        if sender.selectedSegmentIndex == 0 {
            loadAndDisplayDataFromRealmCams()
            tableViewConstraintTop.constant = 25
            roomNameLabel.isHidden = false
        } else {
            loadAndDisplayDataFromRealmDoors()
            tableViewConstraintTop.constant = 5
            roomNameLabel.isHidden = true
        }
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditSegue" {
            if let destinationViewController = segue.destination as? EditViewController {
                if let indexPath = selectedIndexPath {
                    let id = doorDataModel.data[indexPath.section].id
                    destinationViewController.idOfDoor = id
                }
            }
        } else if segue.identifier == "toIntercome" {
            if let destinationViewController = segue.destination as? IntercomViewController {
                if let indexPath = selectedIndexPath {
                    let id = doorDataModel.data[indexPath.section].id
                    destinationViewController.idOfDoor = id
                    destinationViewController.openOrCloseDoor = doorDataModel.data[indexPath.section].lockIcon!
                }
            }
        }
    }
    
    
    // MARK: - TableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        segmentedControl.selectedSegmentIndex == 0 ? camDataModel.data.cameras.count : doorDataModel.data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Creating and casting cell as custom cell for cams
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomTableViewCell
        
        if segmentedControl.selectedSegmentIndex == 0 {
            // Configure the cell for cams
            let imageURL = URL(string: camDataModel.data.cameras[indexPath.section].snapshot)
            cell.configCellVideoImage(imageURL: imageURL)
            cell.camLabel.text = camDataModel.data.cameras[indexPath.section].name
            cell.videoCam.isHidden = false
            cell.onlineLabel.isHidden = false
            cell.favoriteStar.isHidden = !camDataModel.data.cameras[indexPath.section].favorites
            cell.cameraRecorded.isHidden = !camDataModel.data.cameras[indexPath.section].rec
            cell.stackViewTopConstaraint.constant = 223
            cell.lockOn.isHidden = true
            cell.unLock.isHidden = true
            return cell
        } else {
            DispatchQueue.main.async {
                // Configure the cell for doors
                let imageURL = URL(string: self.doorDataModel.data[indexPath.section].snapshot ?? "")
                cell.configCellVideoImage(imageURL: imageURL)
                cell.favoriteStar.isHidden = !self.doorDataModel.data[indexPath.section].favorites
                cell.camLabel.text = self.doorDataModel.data[indexPath.section].name
                cell.cameraRecorded.isHidden = true
                cell.unLock.isHidden = self.doorDataModel.data[indexPath.section].lockIcon!
                cell.lockOn.isHidden = !self.doorDataModel.data[indexPath.section].lockIcon!
            }
            
            // Update cell if image is nil
            if URL(string: doorDataModel.data[indexPath.section].snapshot ?? "") == nil {
                // Configure the cell for doors with nil snapshot
                cell.videoCam.isHidden = true
                cell.onlineLabel.isHidden = true
                cell.stackViewTopConstaraint.constant = 12
                cell.lockOnConstraintTop.constant = 1
                cell.unLockConstraintTop.constant = 1

            } else {
                // Configure the cell for doors with non-nil snapshot
                cell.videoCam.isHidden = false
                cell.onlineLabel.isHidden = false
                cell.stackViewTopConstaraint.constant = 223
                cell.lockOnConstraintTop.constant = 208
                cell.unLockConstraintTop.constant = 208

                // Call the method to load and display the image
                let imageURL = URL(string: doorDataModel.data[indexPath.section].snapshot ?? "")
                cell.configCellVideoImage(imageURL: imageURL)
            }
        }
        return cell
    }
    
    // MARK: - TableView Data Source
    // Adding trailing swipe
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            let addToFavoritesCam = addToFavoritesCams(at: indexPath)
            return UISwipeActionsConfiguration(actions: [addToFavoritesCam])
        } else {
            let editMode = editMode(at: indexPath)
            let addToFavoritesDoor = addToFavoritesDoors(at: indexPath)
            return UISwipeActionsConfiguration(actions: [addToFavoritesDoor, editMode])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if segmentedControl.selectedSegmentIndex == 1 {
            let imageURL = URL(string: doorDataModel.data[indexPath.section].snapshot ?? "")
            if imageURL == nil {
                return 72
            }
        }
        return 279
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if segmentedControl.selectedSegmentIndex == 0 {
            // Checking rooms name by Id camera
            let idOfCamera = camDataModel.data.cameras[indexPath.section].id
            var newRoomValue = ""
            let roomName = camDataModel.data.cameras[indexPath.section].room
            
            switch idOfCamera {
            case 1, 2, 3, 6:
                newRoomValue = roomName ?? ""
            default:
                return
            }
            
            camDataModel.data.cameras[indexPath.section].roomNameLabel = newRoomValue
            roomNameLabel.text = newRoomValue
            
            do {
                let realm = try Realm()
                if let camera = realm.object(ofType: CameraRealm.self, forPrimaryKey: 1) {
                    try realm.write {
                        camera.roomNameLabel = newRoomValue
                    }
                }
            } catch {
                print("Error with Realm: \(error)")
            }
        } else {
            self.selectedIndexPath = indexPath
            self.performSegue(withIdentifier: "toIntercome", sender: nil)
        }
        
    }
    
    
    // MARK: - Unwind segue
    @IBAction func unwindSegueToMain(segue: UIStoryboardSegue) {
        // Saving data from EditViewController to Realm for door name
        if let sourceViewController = segue.source as? EditViewController {
            
            let id = sourceViewController.idOfDoor
            let textField = sourceViewController.editDoorNameTextField.text
            do {
                let realm = try Realm()
                if let doors = realm.object(ofType: DoorRealm.self, forPrimaryKey: id) {
                    try realm.write {
                        doors.name = textField ?? ""
                    }
                }
            } catch {
                print("Error with Realm: \(error)")
            }
            
            // Reading data from Realm for door name
            let realm = try! Realm()
            let doorName = realm.objects(DoorRealm.self).map { $0.name }
            
            if let indexPath = selectedIndexPath, doorName.indices.contains(indexPath.section) {
                let selectedDoorName = doorName[indexPath.section]
                doorDataModel.data[indexPath.section].name = selectedDoorName
                tableView.reloadRows(at: [indexPath], with: .automatic)
                
            } else {
                print("error")
            }
            // Saving data from IntercomeViewController to Realm for door lock ststus
        } else if let sourceViewController = segue.source as? IntercomViewController {
            
            let id = sourceViewController.idOfDoor
            let statusLock = sourceViewController.openOrCloseDoor
            do {
                let realm = try Realm()
                if let doors = realm.object(ofType: DoorRealm.self, forPrimaryKey: id) {
                    try realm.write {
                        doors.lockIcon = statusLock
                    }
                }
            } catch {
                print("Error with Realm: \(error)")
            }
            
            // Reading data from Realm door lock ststus
            let realm = try! Realm()
            let lockIconStatus = realm.objects(DoorRealm.self).map { $0.lockIcon }
            
            if let indexPath = selectedIndexPath, lockIconStatus.indices.contains(indexPath.section) {
                let lockStatus = lockIconStatus[indexPath.section]
                doorDataModel.data[indexPath.section].lockIcon = lockStatus
                print(lockStatus)
                
                
                if let customCell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell {
                    if doorDataModel.data[indexPath.section].lockIcon == true {
                        customCell.unLock.isHidden = true
                        customCell.lockOn.isHidden = false
                    } else {
                        if doorDataModel.data[indexPath.section].lockIcon == false {
                            customCell.unLock.isHidden = false
                            customCell.lockOn.isHidden = true
                            tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                    }

                }
                tableView.reloadData()
            } else {
                print("error")
            }
        }
    }
    
}


// MARK: - Private Methods
extension MainViewController {
    
    // Add to favorites cams for trailing swipe for Cams
    private func addToFavoritesCams(at indexPath: IndexPath) -> UIContextualAction {
        let isFavorite = camDataModel.data.cameras[indexPath.section].favorites
        let favorites = UIContextualAction(style: .normal, title: "") { _, _, completion in
            do {
                let realm = try Realm()
                try realm.write {
                    self.camDataModel.data.cameras[indexPath.section].favorites = isFavorite ? false : true
                    let cameraRealm = realm.object(ofType: CameraRealm.self, forPrimaryKey: self.camDataModel.data.cameras[indexPath.section].id)
                    cameraRealm?.favorites = self.camDataModel.data.cameras[indexPath.section].favorites
                }
                
                if let customCamsCell = self.tableView.cellForRow(at: indexPath) as? CustomTableViewCell {
                    customCamsCell.favoriteStar.isHidden = !self.camDataModel.data.cameras[indexPath.section].favorites
                }
                completion(true)
            } catch let error {
                print("Realm error: \(error)")
                completion(true)
            }
        }
        
        favorites.image = UIImage(named: "star")
        favorites.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        return favorites
    }
    
    // Adding edit mode for the cell with doors section for trailing swipe
    private func editMode(at indexPath: IndexPath) -> UIContextualAction {
        let editMode = UIContextualAction(style: .normal, title: "") { _, _, completion in
            self.selectedIndexPath = indexPath
            self.performSegue(withIdentifier: "toEditSegue", sender: nil)
            completion(true)
        }
        
        editMode.image = UIImage(named: "edit")
        editMode.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        return editMode
    }
    
    // Add to favorites doors for trailing swipe for Doors
    private func addToFavoritesDoors(at indexPath: IndexPath) -> UIContextualAction {
        let isFavorite = doorDataModel.data[indexPath.section].favorites
        let favorites = UIContextualAction(style: .normal, title: "") { _, _, completion in
            do {
                let realm = try Realm()
                try realm.write {
                    self.doorDataModel.data[indexPath.section].favorites = isFavorite ? false : true
                    let doorRealm = realm.object(ofType: DoorRealm.self, forPrimaryKey: self.doorDataModel.data[indexPath.section].id)
                    doorRealm?.favorites = self.doorDataModel.data[indexPath.section].favorites
                }
                
                if let customDoorsCell = self.tableView.cellForRow(at: indexPath) as? CustomTableViewCell {
                    customDoorsCell.favoriteStar.isHidden = !self.doorDataModel.data[indexPath.section].favorites
                }
                completion(true)
            } catch let error {
                print("Realm error: \(error)")
                completion(true)
            }
        }
        
        favorites.image = UIImage(named: "star")
        favorites.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        return favorites
    }
    
    // MARK: Network request
    private func getDoorsDataFromRemoteServer() {
        guard let url = URL(string: "https://cars.cprogroup.ru/api/rubetek/doors/") else { return }
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
                let dataModel = try JSONDecoder().decode(Doors.self, from: remoteData)
                
                // MARK: Saving data to Realm for Doors
                do {
                    let realm = try Realm()
                    try realm.write {
                        realm.add(dataModel.data.map { doorsData in
                            return DoorRealm(value: [
                                "id": doorsData.id,
                                "name": doorsData.name,
                                "snapshot": doorsData.snapshot ?? "",
                                "room": doorsData.room ?? "",
                                "favorites": doorsData.favorites,
                                "lockIcon": doorsData.lockIcon ?? true
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
                    self.doorDataModel = dataModel // Update data model
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
    
    private func getCamsDataFromRemoteServer() {
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
                let dataModel = try JSONDecoder().decode(Cameras.self, from: remoteData)
                
                // MARK: Saving data to Realm for Cams
                do {
                    let realm = try Realm()
                    try realm.write {
                        realm.add(dataModel.data.cameras.map { cameraData in
                            return CameraRealm(value: [
                                "id": cameraData.id,
                                "name": cameraData.name,
                                "snapshot": cameraData.snapshot,
                                "room": cameraData.room ?? "",
                                "roomNameLabel": cameraData.roomNameLabel ?? "",
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
                    self.camDataModel = dataModel // Update data model
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
    private func loadAndDisplayDataFromRealmCams() {
        let realm = try! Realm()
        let cameras = realm.objects(CameraRealm.self) // Loading data from Realm
        
        if cameras.isEmpty {
            // If there is no data in Realm, make a request to the server
            getCamsDataFromRemoteServer()
        } else {
            // If the data is in the Realm display it
            camDataModel.data.cameras = cameras.map { cameraRealm in
                return Camera(
                    name: cameraRealm.name,
                    snapshot: cameraRealm.snapshot,
                    room: cameraRealm.room,
                    roomNameLabel: cameraRealm.roomNameLabel,
                    id: cameraRealm.id,
                    favorites: cameraRealm.favorites,
                    rec: cameraRealm.rec
                )
            }
            self.tableView.reloadData()
            
        }
    }
    
    // The method of loading data from Realm or from the server for Doors
    private func loadAndDisplayDataFromRealmDoors() {
        let realm = try! Realm()
        let doors = realm.objects(DoorRealm.self) // Loading data from Realm
        
        if doors.isEmpty {
            // If there is no data in Realm, make a request to the server
            getDoorsDataFromRemoteServer()
        } else {
            // If the data is in the Realm display it
            doorDataModel.data = doors.map { doorsRealm in
                return Datum(
                    name: doorsRealm.name,
                    room: doorsRealm.room,
                    id: doorsRealm.id,
                    favorites: doorsRealm.favorites,
                    snapshot: doorsRealm.snapshot,
                    lockIcon: doorsRealm.lockIcon
                )
            }
            self.tableView.reloadData()
        }
    }
    
    // Method to update data via pull-to-refresh
    @objc private func refreshData(_ sender: UIRefreshControl) {
        segmentedControl.selectedSegmentIndex == 0 ? loadAndDisplayDataFromRealmCams() : loadAndDisplayDataFromRealmDoors()
        sender.endRefreshing()
    }
    
}

