//
//  ViewController.swift
//  VideoSurveillance
//
//  Created by Yury on 11/08/2023.
//

import UIKit

class CamScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IB Outlets
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private var newData = Cameras.shared // Data from remote server
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding delegates and data source for tableView
        tableView.dataSource = self
        tableView.delegate = self
        
        
        
        segmentedControl.addUnderlineForSelectedSegment() // Adding underline for segmentedControl
        
        getDataFromRemoteServer()
    }
    
    // MARK: - IB Actions
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        segmentedControl.changeUnderlinePosition()
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let asdadsasd = "awdadw"
        case 1:
            let asdadasd = "adawdadw"
        default:
            return
        }
    }
    
    // MARK: - TableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return newData.data.cameras.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "camsCell", for: indexPath) as! CamsTableViewCell
        
        // Временнный костыль чтобы разделить ячейки за счет секций
        switch indexPath.section {
        case 0:
            cell.configCamsCellVideoImage(model: newData, indexPath: indexPath, tableView: tableView)
            cell.camLabel.text = newData.data.cameras[indexPath.row].name
            cell.favoriteStar.isHidden = newData.data.cameras[indexPath.row].favorites
            cell.cameraRecorded.isHidden = newData.data.cameras[indexPath.row].rec
            return cell
        case 1:
            cell.camLabel.text = newData.data.cameras[indexPath.row + 1].name
            cell.favoriteStar.isHidden = newData.data.cameras[indexPath.row + 1].favorites
            cell.cameraRecorded.isHidden = newData.data.cameras[indexPath.row + 1].rec
            cell.configCamsCellVideoImage(model: newData, indexPath: indexPath, tableView: tableView)
            return cell
        case 2:
            cell.camLabel.text = newData.data.cameras[indexPath.row + 2].name
            cell.favoriteStar.isHidden = newData.data.cameras[indexPath.row + 2].favorites
            cell.cameraRecorded.isHidden = newData.data.cameras[indexPath.row + 2].rec
            cell.configCamsCellVideoImage(model: newData, indexPath: indexPath, tableView: tableView)
            return cell
        default:
            cell.camLabel.text = newData.data.cameras[indexPath.row + 3].name
            cell.favoriteStar.isHidden = newData.data.cameras[indexPath.row + 3].favorites
            cell.cameraRecorded.isHidden = newData.data.cameras[indexPath.row + 3].rec
            cell.configCamsCellVideoImage(model: newData, indexPath: indexPath, tableView: tableView)
            return cell
        }
        
        
    }
    
    // MARK: - TableView Data Source
    // Adding trailing swipe
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let addTofavorites = addToFavorites(at: indexPath)
        return UISwipeActionsConfiguration(actions: [addTofavorites])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let idOfCamera = newData.data.cameras[indexPath.row].id
        
        switch idOfCamera {
        case 1:
            roomNameLabel.text = newData.data.cameras[indexPath.row].room
        case 2:
            roomNameLabel.text = newData.data.cameras[indexPath.row].room
        case 3:
            roomNameLabel.text = newData.data.cameras[indexPath.row].room
        case 6:
            roomNameLabel.text = newData.data.cameras[indexPath.row].room
        default:
            return
        }
    }
    
    
}


// Titile for the section to raise its table higher
//func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int
//) -> String? {
//    if section == 0 {
//        return "title"
//    }
//    return nil
//}
//
//// Hiding title
//func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//    guard let header = view as? UITableViewHeaderFooterView else { return }
//    header.textLabel?.textColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1.0)
//}



// MARK: - Private Methods
extension CamScreenViewController {
    
    // Add to favorites cams for trailing swipe
    private func addToFavorites(at indexPath: IndexPath) -> UIContextualAction {
        let isFavorite = newData.data.cameras[indexPath.row].favorites
        let favorites = UIContextualAction(style: .normal, title: "") { _, _, completion in
            self.newData.data.cameras[indexPath.row].favorites = isFavorite ? false : true
            if let customCamsCell = self.tableView.cellForRow(at: indexPath) as? CamsTableViewCell {
                customCamsCell.favoriteStar.isHidden = self.newData.data.cameras[indexPath.row].favorites
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
            
            guard let remtoteData = data else { return }
            do {
                self.newData = try JSONDecoder().decode(Cameras.self, from: remtoteData)
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

