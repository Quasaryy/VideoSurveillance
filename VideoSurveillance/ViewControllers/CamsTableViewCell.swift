//
//  CamsTableViewCell.swift
//  VideoSurveillance
//
//  Created by Yury on 12/08/2023.
//

import UIKit

class CamsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var cameraRecorded: UIImageView!
    @IBOutlet weak var camLabel: UILabel!
    @IBOutlet weak var videoCam: UIImageView!
    @IBOutlet weak var favoriteStar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        

        // Configure the view for the selected state
    }


}

extension CamsTableViewCell {
    func configCamsCellVideoImage(model: Cameras, indexPath: IndexPath, tableView: UITableView) {
                        
            guard let url = URL(string: model.data.cameras[indexPath.row].snapshot) else { return }
            URLSession.shared.dataTask(with: url) { data, _, _ in
                
                guard let dataSource = data else { return }
                let imageSource = UIImage(data: dataSource)
                DispatchQueue.main.async {
                    self.videoCam.image = imageSource
                }
            }.resume()
            
    }
}
