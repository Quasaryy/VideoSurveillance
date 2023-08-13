//
//  CamsTableViewCell.swift
//  VideoSurveillance
//
//  Created by Yury on 12/08/2023.
//

import UIKit

class DoorsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lockOnTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameAndStatusStackView: UIStackView!
    @IBOutlet weak var nameAndStatusStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var onlineLabel: UILabel!
    @IBOutlet weak var doorNameLabel: UILabel!
    @IBOutlet weak var favoriteStarDoors: UIImageView!
    @IBOutlet weak var videoCameraDoors: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureShadowAndBorders() // For shadow and borders of the cell
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        
        // Configure the view for the selected state
    }
    
}

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
        self.layer.shadowOpacity = 1
        
        self.layer.borderWidth = 0.3
        self.layer.borderColor = UIColor(red: 219/255, green: 219/255, blue: 219/255, alpha: 1).cgColor
    }
}
