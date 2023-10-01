//
//  extensions.swift
//  VideoSurveillance
//
//  Created by Yury on 12/08/2023.
//

import Foundation
import UIKit

extension UISegmentedControl {
    
    func changeBackGround() {
        let backgroundImage = UIImage.getColoredRectImageWith(color: UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1.0).cgColor, andSize: self.bounds.size)
        self.setBackgroundImage(backgroundImage, for: .normal, barMetrics: .default)
        self.setBackgroundImage(backgroundImage, for: .selected, barMetrics: .default)
        self.setBackgroundImage(backgroundImage, for: .highlighted, barMetrics: .default)
    }
    
    func changeDeviderImage() {
        let deviderImage = UIImage.getColoredRectImageWith(color: UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1.0).cgColor, andSize: CGSize(width: 1.0, height: self.bounds.size.height))
        self.setDividerImage(deviderImage, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
    }
    
    func removeBorder() {
        changeBackGround()
        changeDeviderImage()
    }
    
    // Set custom font and font size
    func changeFont() {
        guard let customFont = UIFont(name: "Circe-regular", size: 17.0) else { return }
        
        let attr = NSDictionary(object: customFont, forKey: NSAttributedString.Key.font as NSCopying)
        self.setTitleTextAttributes(attr as? [NSAttributedString.Key: AnyObject], for: .normal)
    }
    
    func addUnderlineForSelectedSegment(){
        removeBorder()
        changeFont()
        let underlineWidth: CGFloat = self.bounds.size.width / CGFloat(self.numberOfSegments)
        let underlineHeight: CGFloat = 4.0
        let underlineXPosition = CGFloat(selectedSegmentIndex * Int(underlineWidth))
        let underLineYPosition = self.bounds.size.height - 4.0
        let underlineFrame = CGRect(x: underlineXPosition, y: underLineYPosition, width: underlineWidth, height: underlineHeight)
        let underline = UIView(frame: underlineFrame)
        underline.backgroundColor = UIColor(red: 75/255, green: 166/255, blue: 238/255, alpha: 1.0)
        underline.tag = 1
        self.addSubview(underline)
    }
    
    func changeUnderlinePosition(){
        guard let underline = self.viewWithTag(1) else {return}
        let underlineFinalXPosition = (self.bounds.width / CGFloat(self.numberOfSegments)) * CGFloat(selectedSegmentIndex)
        UIView.animate(withDuration: 0.1, animations: {
            underline.frame.origin.x = underlineFinalXPosition
        })
    }
}
