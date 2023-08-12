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
