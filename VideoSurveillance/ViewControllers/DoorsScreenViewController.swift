//
//  ViewController.swift
//  VideoSurveillance
//
//  Created by Yury on 11/08/2023.
//

import UIKit

class DoorsScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IB Outlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private var newDataModel = Doors.shared // Model for remote data
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding delegates and data source for tableView
        tableView.dataSource = self
        tableView.delegate = self
        
        
        // Adding underline for segmentedControl
        segmentedControl.addUnderlineForSelectedSegment()
        
        // Getting remote data
        getDataFromRemoteServer()
    }
    
    // MARK: - IB Actions
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        
    }
    
    // MARK: - TableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return newDataModel.data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "doorsCell", for: indexPath) as! DoorsTableViewCell
        
        // Hide the image if it is not on the remote server
        if newDataModel.data[indexPath.section].snapshot == nil {
            cell.videoCameraDoors.isHidden = true
            cell.onlineLabel.isHidden = true
            
            
            cell.nameAndStatusStackViewTopConstraint.constant = 12
            cell.lockOnTopConstraint.constant = 0
        }
        
        // Configure the cell
        cell.configDoorsCellVideoImage(model: newDataModel, indexPath: indexPath, tableView: tableView)
        cell.doorNameLabel.text = newDataModel.data[indexPath.section].name
        cell.favoriteStarDoors.isHidden = !newDataModel.data[indexPath.section].favorites
        
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
    
    // Add to favorites cams for trailing swipe
    private func addToFavorites(at indexPath: IndexPath) -> UIContextualAction {
        let isFavorite = newDataModel.data[indexPath.section].favorites
        let favorites = UIContextualAction(style: .normal, title: "") { _, _, completion in
            self.newDataModel.data[indexPath.section].favorites = isFavorite ? false : true
            if let customCamsCell = self.tableView.cellForRow(at: indexPath) as? DoorsTableViewCell {
                customCamsCell.favoriteStarDoors.isHidden = !self.newDataModel.data[indexPath.section].favorites
            }
            completion(true)
        }
        
        favorites.image = UIImage(named: "star")
        favorites.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        return favorites
    }
    
    // Adding edit mode for the cell with doors section for trailing swipe
    private func editMode(at indexPath: IndexPath) -> UIContextualAction {
        let editMode = UIContextualAction(style: .normal, title: "") { _, _, completion in
            
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
            
            guard let remtoteData = data else { return }
            do {
                self.newDataModel = try JSONDecoder().decode(Doors.self, from: remtoteData)
                DispatchQueue.main.async {
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
    
}

