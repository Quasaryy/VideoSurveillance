//
//  ViewController.swift
//  VideoSurveillance
//
//  Created by Yury on 11/08/2023.
//

import UIKit

class CamScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - IB Outlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private var favorite = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        segmentedControl.addUnderlineForSelectedSegment()
    }
    
    // MARK: - IB Actions
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        segmentedControl.changeUnderlinePosition()
    }
    
    // MARK: - TableView Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "camsCell", for: indexPath) as! CamsTableViewCell
        
        cell.camLabel.text = "sdfsdfsdf"
        cell.favoriteStar.isHidden = true
        return cell
        
    }
    
    // MARK: - TableView Data Source
    // Adding trailing swipe
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let addTofavorites = addToFavorites(at: indexPath)
        return UISwipeActionsConfiguration(actions: [addTofavorites])
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
        let isFavorite = favorite
        let favorites = UIContextualAction(style: .normal, title: "") { _, _, completion in
            self.favorite = isFavorite ? false : true
            if let customCell = self.tableView.cellForRow(at: indexPath) as? CamsTableViewCell {
                customCell.favoriteStar.isHidden = self.favorite
            }
            completion(true)
        }
        
        favorites.image = UIImage(named: "star")
        favorites.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1)
        return favorites
    }
    
}

