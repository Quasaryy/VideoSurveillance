//
//  CamsTableViewCell.swift
//  VideoSurveillance
//
//  Created by Yury on 12/08/2023.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var onlineLabel: UILabel!
    @IBOutlet weak var cameraRecorded: UIImageView!
    @IBOutlet weak var camLabel: UILabel!
    @IBOutlet weak var videoCam: UIImageView!
    @IBOutlet weak var favoriteStar: UIImageView!
    @IBOutlet weak var stackViewTopConstaraint: NSLayoutConstraint!
    @IBOutlet weak var unLock: UIImageView!
    @IBOutlet weak var unLockConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var lockOn: UIImageView!
    @IBOutlet weak var lockOnConstraintTop: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var imageURL: URL?
    
    // MARK: - awakeFromNib
    
    override func awakeFromNib() {
        super.awakeFromNib()
        UIManager.shared.configureShadowAndBordersForCell(cell: self) // For shadow and borders of the cell
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

// MARK: - Methods

extension CustomTableViewCell {
    
    // MARK: Cell config
    
    // Configuration the cell for images for Cams model
    func configCellVideoImage(imageURL: URL?) {
        guard let imageURL = imageURL else {
            videoCam.image = nil
            return
        }
        
        self.imageURL = imageURL
        videoCam.image = nil
        
        URLSession.shared.dataTask(with: imageURL) { [weak self] data, _, _ in
            guard let self = self, let data = data, self.imageURL == imageURL else { return }
            DispatchQueue.main.async {
                self.videoCam.image = UIImage(data: data)
            }
        }.resume()
    }
    
    // Configure the cell for cams
    func configCellForCams(indexPath: IndexPath, model: Cameras) {
        let imageURL = URL(string: model.data.cameras[indexPath.section].snapshot)
        configCellVideoImage(imageURL: imageURL)
        camLabel.text = model.data.cameras[indexPath.section].name
        videoCam.isHidden = false
        onlineLabel.isHidden = false
        favoriteStar.isHidden = !model.data.cameras[indexPath.section].favorites
        cameraRecorded.isHidden = !model.data.cameras[indexPath.section].rec
        stackViewTopConstaraint.constant = 223
        lockOn.isHidden = true
        unLock.isHidden = true
    }
    
    // Configure the cell for doors
    func configCellForDoors(indexPath: IndexPath, model: Doors) {
        DispatchQueue.main.async {
            // Configure the cell for doors
            let imageURL = URL(string: model.data[indexPath.section].snapshot ?? "")
            self.configCellVideoImage(imageURL: imageURL)
            self.favoriteStar.isHidden = !model.data[indexPath.section].favorites
            self.camLabel.text = model.data[indexPath.section].name
            self.cameraRecorded.isHidden = true
            self.unLock.isHidden = model.data[indexPath.section].lockIcon ?? true
            self.lockOn.isHidden = !(model.data[indexPath.section].lockIcon ?? true)
        }
    }
    
    // Configure the cell for doors with nil snapshot
    func configCellForDoorsIfSnapshotNil() {
        videoCam.isHidden = true
        onlineLabel.isHidden = true
        stackViewTopConstaraint.constant = 12
        lockOnConstraintTop.constant = 1
        unLockConstraintTop.constant = 1
    }
    
    // Configure the cell for doors with non-nil snapshot
    func configCellForDoorsIfSnapshotIsNotNil(indexPath: IndexPath, model: Doors) {
        // Configure the cell for doors with non-nil snapshot
        videoCam.isHidden = false
        onlineLabel.isHidden = false
        stackViewTopConstaraint.constant = 223
        lockOnConstraintTop.constant = 208
        unLockConstraintTop.constant = 208
        
        // Call the method to load and display the image
        let imageURL = URL(string: model.data[indexPath.section].snapshot ?? "")
        configCellVideoImage(imageURL: imageURL)
    }
    
    func finalCellConfig(indexPath: IndexPath, doorsModel: Doors) {
        // Configure the cell for doors
        configCellForDoors(indexPath: indexPath, model: doorsModel)
        
        // Update cell if image is nil
        if URL(string: doorsModel.data[indexPath.section].snapshot ?? "") == nil {
            
            // Configure the cell for doors with nil snapshot
            configCellForDoorsIfSnapshotNil()
            
        } else {
            // Configure the cell for doors with non-nil snapshot
            configCellForDoorsIfSnapshotIsNotNil(indexPath: indexPath, model: doorsModel)
        }
    }
    
}
