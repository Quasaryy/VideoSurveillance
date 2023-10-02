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
    
    var camDataModel = Cameras.shared // Model for remote data
    var doorDataModel = Doors.shared // Model for remote data
    private let refreshControl = UIRefreshControl()
    var selectedIndexPath: IndexPath?
    let realm = DataManagerForRealm.shared.realm
    let cameraRowHeight: CGFloat = 279
    let doorRowHeight: CGFloat = 72
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup UI
        UIManager.shared.setupUIForMainScreen(tableView: tableView, segmentedControl: segmentedControl, refreshControl: refreshControl, roomNameLabel: roomNameLabel, mainController: self)
        
    }
    
    // MARK: - IB Actions
    
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        ActionManager.shared.handleSegmentChange(for: sender, constraint: tableViewConstraintTop, roomNameLabel: roomNameLabel, tableView: tableView)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as? CustomTableViewCell else { return UITableViewCell() }
        
        if segmentedControl.selectedSegmentIndex == 0 {
            
            // Configure the cell for cams
            cell.configCellForCams(indexPath: indexPath, model: camDataModel)
            
            return cell
        } else {
            
            cell.finalCellConfig(indexPath: indexPath, doorsModel: doorDataModel)
        }
        return cell
    }
    
    // MARK: - Table View delegate
    
    // Adding trailing swipe
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            
        if segmentedControl.selectedSegmentIndex == 0 {
            let addToFavoritesCam = SwipeManager.shared.addToFavoritesCams(at: indexPath, using: camDataModel, for: tableView)
            return UISwipeActionsConfiguration(actions: [addToFavoritesCam])
        } else {
            let editMode = SwipeManager.shared.editMode(at: indexPath, using: self)
            let addToFavoritesDoor = SwipeManager.shared.addToFavoritesDoors(at: indexPath, using: doorDataModel, for: tableView)
            return UISwipeActionsConfiguration(actions: [addToFavoritesDoor, editMode])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if segmentedControl.selectedSegmentIndex == 1 {
            let imageURL = URL(string: doorDataModel.data[indexPath.section].snapshot ?? "")
            if imageURL == nil {
                return doorRowHeight
            }
        }
        return cameraRowHeight
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
        NavigationManager.shared.prepare(for: segue, withDataModel: doorDataModel, andSelectedIndexPath: selectedIndexPath)
    }
    
    // MARK: Unwind segue
    
    @IBAction func unwindSegueToMain(segue: UIStoryboardSegue) {
        NavigationManager.shared.unwindSegueLogic(segue: segue, doorDataModel: &doorDataModel, tableView: tableView, realm: realm, selectedIndexPath: selectedIndexPath)
    }
    
}

// MARK: - Private Methods

extension MainViewController {
    
    // Method to update data via pull-to-refresh
    @objc
    func refreshData(_ sender: UIRefreshControl) {
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
