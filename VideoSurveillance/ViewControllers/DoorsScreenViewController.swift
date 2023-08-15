//
//  ViewController.swift
//  VideoSurveillance
//
//  Created by Yury on 11/08/2023.
//

import UIKit
import RealmSwift

class DoorsScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IB Outlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    var selectedIndexPath: IndexPath?
    private var newDataModel = Doors.shared // Model for remote data and Realm
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding delegates and data source for tableView
        tableView.dataSource = self
        tableView.delegate = self
        
        
        // Adding underline for segmentedControl
        segmentedControl.addUnderlineForSelectedSegment()
        
        // Try loading data from Realm on startup
        loadAndDisplayDataFromRealm()
        
        // Adding refresh control for TableView
        tableView.refreshControl = refreshControl
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor(red:0.25, green:0.75, blue:0.85, alpha:1.0)
        refreshControl.attributedTitle = NSAttributedString(string: "Updatinging data from Realm")
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSegue" {
            if let destinationVC = segue.destination as? EditViewController {
                if let indexPath = selectedIndexPath {
                    let id = newDataModel.data[indexPath.section].id
                    destinationVC.idOfDoor = id
                }
            }
        }
    }
    
    @IBAction func unwindSegueToDoors(segue: UIStoryboardSegue) {
        guard let sourceViewController = segue.source as? EditViewController else { return }
        
        // Saving data from EditViewController to Realm
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
        
        // Reading data from Realm
        let realm = try! Realm()
        let doorName = realm.objects(DoorRealm.self).map { $0.name }
        
        if let indexPath = selectedIndexPath, doorName.indices.contains(indexPath.section) {
            let selectedDoorName = doorName[indexPath.section]
            newDataModel.data[indexPath.section].name = selectedDoorName
            
            tableView.reloadRows(at: [indexPath], with: .none)
        } else {
            print("error")
        }
    }
    
    // MARK: - TableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return newDataModel.data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Creating and casting cell as custom cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "doorsCell", for: indexPath) as! DoorsTableViewCell
        
        // Hide the image if it is not on the remote server
        if newDataModel.data[indexPath.section].snapshot == nil {
            cell.updateCellState(model: newDataModel, indexPath: indexPath, tableView: tableView)
        }
        
        // Configure the cell
        cell.configDoorsCellVideoImage(model: newDataModel, indexPath: indexPath, tableView: tableView)
        cell.doorNameLabel.text = newDataModel.data[indexPath.section].name
        cell.favoriteStarDoors.isHidden = !newDataModel.data[indexPath.section].favorites
        
        cell.unLock.isHidden = true
        
        return cell
    }
    
    // MARK: - TableView Data Source
    // Adding trailing swipe
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editMode = editMode(at: indexPath)
        let addTofavorites = addToFavorites(at: indexPath)
        return UISwipeActionsConfiguration(actions: [addTofavorites, editMode])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Changing lock icons
        if let customCell = tableView.cellForRow(at: indexPath) as? DoorsTableViewCell {
            customCell.isLocked = !customCell.isLocked
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if newDataModel.data[indexPath.section].snapshot == nil {
            return 72
        } else {
            return 279
        }
    }
    
    
}


// MARK: - Private Methods
extension DoorsScreenViewController {
    
    // Add to favorites doors for trailing swipe
    private func addToFavorites(at indexPath: IndexPath) -> UIContextualAction {
        let isFavorite = newDataModel.data[indexPath.section].favorites
        let favorites = UIContextualAction(style: .normal, title: "") { _, _, completion in
            do {
                let realm = try Realm()
                try realm.write {
                    self.newDataModel.data[indexPath.section].favorites = isFavorite ? false : true
                    let doorRealm = realm.object(ofType: DoorRealm.self, forPrimaryKey: self.newDataModel.data[indexPath.section].id)
                    doorRealm?.favorites = self.newDataModel.data[indexPath.section].favorites
                }
                
                if let customDoorsCell = self.tableView.cellForRow(at: indexPath) as? DoorsTableViewCell {
                    customDoorsCell.favoriteStarDoors.isHidden = !self.newDataModel.data[indexPath.section].favorites
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
            self.performSegue(withIdentifier: "editSegue", sender: nil)
            completion(true)
        }
        
        editMode.image = UIImage(named: "edit")
        editMode.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        return editMode
    }
    
    
    
    // MARK: Network request
    private func getDataFromRemoteServer() {
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
                
                // MARK: Saving data to Realm
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
                    self.newDataModel = dataModel // Update data model
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
        let realm = try! Realm()
        let doors = realm.objects(DoorRealm.self) // Loading data from Realm
        
        if doors.isEmpty {
            // If there is no data in Realm, make a request to the server
            getDataFromRemoteServer()
        } else {
            // If the data is in the Realm display it
            newDataModel.data = doors.map { doorsRealm in
                return Datum(
                    name: doorsRealm.name,
                    room: doorsRealm.room,
                    id: doorsRealm.id,
                    favorites: doorsRealm.favorites,
                    snapshot: doorsRealm.snapshot
                )
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // Method to update data via pull-to-refresh
    @objc private func refreshData(_ sender: UIRefreshControl) {
        loadAndDisplayDataFromRealm()
        sender.endRefreshing()
    }
    
}

