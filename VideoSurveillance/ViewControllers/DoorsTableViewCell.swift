//
//  CamsTableViewCell.swift
//  VideoSurveillance
//
//  Created by Yury on 12/08/2023.
//

import UIKit
import RealmSwift

class DoorsTableViewCell: UITableViewCell, DoorsScreenViewControllerDelegate {
    
    
    
    
    
    // MARK: - IB Outlets
    @IBOutlet weak var unLockTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var unLock: UIImageView!
    @IBOutlet weak var lockOn: UIImageView!
    @IBOutlet weak var lockOnTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameAndStatusStackView: UIStackView!
    @IBOutlet weak var nameAndStatusStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var onlineLabel: UILabel!
    @IBOutlet weak var doorNameLabel: UILabel!
    @IBOutlet weak var favoriteStarDoors: UIImageView!
    @IBOutlet weak var videoCameraDoors: UIImageView!
    
    
    // MARK: - Properties
    var isLocked: Bool = false {
        didSet {
            lockOn.isHidden = isLocked
            unLock.isHidden = !isLocked
        }
        
        
        
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureShadowAndBorders() // For shadow and borders of the cell
        

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
                
        
    }
    
}

// MARK: - Methods
extension DoorsTableViewCell {
    // Configuration the cell for images
    func configDoorsCellVideoImage(model: Doors, indexPath: IndexPath, tableView: UITableView) {
        
        guard let url = URL(string: model.data[indexPath.section].snapshot ?? "") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            
            guard let dataSource = data else { return }
            let imageSource = UIImage(data: dataSource)
            DispatchQueue.main.async {
                self.videoCameraDoors.image = imageSource
            }
        }.resume()
    }
    
    // Add shadow and borders for the cell
    func configureShadowAndBorders() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.5
        
        self.layer.borderWidth = 0.3
        self.layer.borderColor = UIColor(red: 219/255, green: 219/255, blue: 219/255, alpha: 1).cgColor
    }
    
    // Update constraints and visibility of some elements
    func updateCellWithSnapshotStatus(hidden: Bool) {
        videoCameraDoors.isHidden = hidden
        onlineLabel.isHidden = hidden
        nameAndStatusStackViewTopConstraint.constant = 12
        lockOnTopConstraint.constant = 20
        unLockTopConstraint.constant = 19
    }
    
    func updateCellState(model: Doors, indexPath: IndexPath, tableView: UITableView) {
        updateCellWithSnapshotStatus(hidden: true)
        tableView.rowHeight = 72
    }
    
    
}
