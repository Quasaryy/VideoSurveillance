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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        segmentedControl.addUnderlineForSelectedSegment()
        segmentedControl.layer.cornerRadius = 0
        
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
        return cell
        
    }
    
    // MARK: - TableView Data Source
    // Titile for the section to raise its table higher
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int
    ) -> String? {
        if section == 0 {
            return "title"
        }
        return nil
    }
    
        // Hiding title
        func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
            guard let header = view as? UITableViewHeaderFooterView else { return }
            header.textLabel?.textColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1.0)
        }
    
}



