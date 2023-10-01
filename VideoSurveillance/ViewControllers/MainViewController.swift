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
    private let realm = DataManagerForRealm.shared.realm
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding delegates and data source for tableView
        tableView.dataSource = self
        tableView.delegate = self
        
        // Checking Realm location
        Logger.logRealmLocation(realm)
        
        // Adding underline for segmentedControl
        segmentedControl.addUnderlineForSelectedSegment()
        
        // Try loading data from Realm on startup
        NetworkManager.shared.getDoorsDataFromRemoteServerIfNeeded(tableView: self.tableView) { doorsModel in
                self.doorDataModel = doorsModel
            }
        NetworkManager.shared.getCamerasDataFromRemoteServerIfNeeded(tableView: tableView) { camsModel in
            self.camDataModel = camsModel
        }
        
        // Adding refresh control for TableView
        tableView.refreshControl = refreshControl
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor(red: 63/255, green: 192/255, blue: 216/255, alpha: 1.0)
        refreshControl.attributedTitle = NSAttributedString(string: "Updating data from Realm")
        
        // Loading room name
        roomNameLabel.text = camDataModel.data.cameras.first?.roomNameLabel ?? "Название комнаты"
    }
    
    // MARK: - IB Actions
    
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        sender.changeUnderlinePosition()
        
        if sender.selectedSegmentIndex == 0 {
            
            let tableViewTopConstant: CGFloat = 25.0
            tableViewConstraintTop.constant = tableViewTopConstant
            roomNameLabel.isHidden = false
        } else {
            let tableViewTopConstant: CGFloat = 5.0
            tableViewConstraintTop.constant = tableViewTopConstant
            roomNameLabel.isHidden = true
        }
        tableView.reloadData()
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        segmentedControl.selectedSegmentIndex == 0 ? camDataModel.data.cameras.count : doorDataModel.data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Creating and casting cell as custom cell for cams and doors
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomTableViewCell
        
        if segmentedControl.selectedSegmentIndex == 0 {
            
            // Configure the cell for cams
            cell.configCellForCams(indexPath: indexPath, model: camDataModel)
            
            return cell
        } else {
            
            cell.finalCellConfig(indexPath: indexPath, doorsModel: doorDataModel)
        }
        return cell
    }
    
    // MARK: - TableView delegate
    
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
                Logger.logRealmError(error)
            }
        } else {
            self.selectedIndexPath = indexPath
            self.performSegue(withIdentifier: "toIntercome", sender: nil)
        }
        
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditSegue", let destinationViewController = segue.destination as? EditViewController, let indexPath = selectedIndexPath {
            let id = doorDataModel.data[indexPath.section].id
            destinationViewController.doorId = id
        } else if segue.identifier == "toIntercome", let destinationViewController = segue.destination as? IntercomeViewController, let indexPath = selectedIndexPath {
            let id = doorDataModel.data[indexPath.section].id
            destinationViewController.idOfDoor = id
            destinationViewController.openOrCloseDoor = doorDataModel.data[indexPath.section].lockIcon ?? true
        }
    }
    
    // MARK: Unwind segue
    
    @IBAction func unwindSegueToMain(segue: UIStoryboardSegue) {
        // Saving data from EditViewController to Realm for door name
        if let sourceViewController = segue.source as? EditViewController {
            
            let id = sourceViewController.doorId
            let textField = sourceViewController.editDoorNameTextField.text
            
            // Saving data to Realm for door name
            let doors = realm.object(ofType: DoorRealm.self, forPrimaryKey: id)
            DataManagerForRealm.shared.saveObjectsToRealm(doors) {
                doors?.name = textField ?? ""
            }
            
            // Reading data from Realm for door name
            let doorName = DataManagerForRealm.shared.loadFromRealm(DoorRealm.self).compactMap { (datum: Datum) in
                return datum.name
            }
            
            if let indexPath = selectedIndexPath, doorName.indices.contains(indexPath.section) {
                
                let selectedDoorName = doorName[indexPath.section]
                doorDataModel.data[indexPath.section].name = selectedDoorName
                tableView.reloadRows(at: [indexPath], with: .automatic)
                
            } else {
                Logger.log("error")
            }
            
            // Saving data from IntercomeViewController to Realm for door lock ststus
        } else if let sourceViewController = segue.source as? IntercomeViewController {
            
            let id = sourceViewController.idOfDoor
            let statusLock = sourceViewController.openOrCloseDoor
            
            if let doors = realm.object(ofType: DoorRealm.self, forPrimaryKey: id) {
                DataManagerForRealm.shared.saveObjectsToRealm(doors) {
                    doors.lockIcon = statusLock
                }
            }
        }
        
        // Reading data from Realm door lock status
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
            tableView.reloadData()
        } else {
            Logger.log("error")
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
                    self.camDataModel.data.cameras[indexPath.section].favorites = !isFavorite
                    let cameraRealm = realm.object(ofType: CameraRealm.self, forPrimaryKey: self.camDataModel.data.cameras[indexPath.section].id)
                    cameraRealm?.favorites = self.camDataModel.data.cameras[indexPath.section].favorites
                }
                
                if let customCamsCell = self.tableView.cellForRow(at: indexPath) as? CustomTableViewCell {
                    customCamsCell.favoriteStar.isHidden = !self.camDataModel.data.cameras[indexPath.section].favorites
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
                    self.doorDataModel.data[indexPath.section].favorites = !isFavorite
                    let doorRealm = realm.object(ofType: DoorRealm.self, forPrimaryKey: self.doorDataModel.data[indexPath.section].id)
                    doorRealm?.favorites = self.doorDataModel.data[indexPath.section].favorites
                }
                
                if let customDoorsCell = self.tableView.cellForRow(at: indexPath) as? CustomTableViewCell {
                    customDoorsCell.favoriteStar.isHidden = !self.doorDataModel.data[indexPath.section].favorites
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
    
    // Method to update data via pull-to-refresh
    @objc private func refreshData(_ sender: UIRefreshControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            
            let camsFromRealm: [Camera] = DataManagerForRealm.shared.loadFromRealm(CameraRealm.self)
            let camerasModel = Cameras(success: true, data: DataClass(room: [], cameras: camsFromRealm))
            camDataModel = camerasModel
            
            tableView.reloadData()
        } else {
            let doorsFromRealm: [Datum] = DataManagerForRealm.shared.loadFromRealm(DoorRealm.self)
            let doorsModel = Doors(success: true, data: doorsFromRealm)
            doorDataModel = doorsModel
            
            tableView.reloadData()
        }
        sender.endRefreshing()
    }
    
}

