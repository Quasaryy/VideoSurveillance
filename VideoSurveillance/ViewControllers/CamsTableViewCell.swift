//
//  CamsTableViewCell.swift
//  VideoSurveillance
//
//  Created by Yury on 12/08/2023.
//

import UIKit

class CamsTableViewCell: UITableViewCell {
    
    // MARK: - IB Outlets
    @IBOutlet weak var onlineLabel: UILabel!
    @IBOutlet weak var cameraRecorded: UIImageView!
    @IBOutlet weak var camLabel: UILabel!
    @IBOutlet weak var videoCam: UIImageView!
    @IBOutlet weak var favoriteStar: UIImageView!
    @IBOutlet weak var stackViewTopConstaraint: NSLayoutConstraint!
    
    var imageURL: URL?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureShadowAndBorders() // For shadow and borders of the cell
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        
        // Configure the view for the selected state
    }
    
}

// MARK: - Methods
extension CamsTableViewCell {
    // Configuration the cell for images for Cams model
    func configCellVideoImageCams(imageURL: URL?) {
        guard let imageURL = imageURL else {
            videoCam.image = nil
            return
        }
        print("Loading image from: \(imageURL)")

        self.imageURL = imageURL
        videoCam.image = nil

        URLSession.shared.dataTask(with: imageURL) { [weak self] data, _, _ in
            guard let self = self, let dataSource = data, self.imageURL == imageURL else { return }
            let imageSource = UIImage(data: dataSource)
            DispatchQueue.main.async {
                self.videoCam.image = imageSource
            }
        }.resume()
    }
    
    // Configuration the cell for images for Door model
    func configCellVideoImageDoors(imageURL: URL?) {
        guard let imageURL = imageURL else {
            videoCam.image = nil
            return
        }

        self.imageURL = imageURL
        videoCam.image = nil

        URLSession.shared.dataTask(with: imageURL) { [weak self] data, _, _ in
            guard let self = self, let dataSource = data, self.imageURL == imageURL else { return }
            let imageSource = UIImage(data: dataSource)
            DispatchQueue.main.async {
                self.videoCam.image = imageSource
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
    
    
}
