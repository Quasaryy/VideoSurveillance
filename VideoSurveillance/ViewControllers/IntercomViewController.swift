//
//  DomophoneViewController.swift
//  VideoSurveillance
//
//  Created by Yury on 17/08/2023.
//

import UIKit

class IntercomViewController: UIViewController {

    // MARK: - IB Outlets
    @IBOutlet weak var intercomImage: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var viewWithKey: UIView!
    @IBOutlet weak var doorOpenLabel: UILabel!
    
    // MARK: - Properties
    private var hideOrNot = true
    private var openOrCloseDoor = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add shadow and borders for the bottom views
        configureShadowAndBorders(for: bottomView)
        viewWithKey.layer.cornerRadius = 12
    }
    
    
    
    @IBAction func keyButtonTapped(_ sender: UIButton) {
        if openOrCloseDoor == false {
            doorOpenLabel.text = "Дверь открыта - закрыть дверь"
            openOrCloseDoor = !openOrCloseDoor
        } else {
            doorOpenLabel.text = "Открыть дверь"
            openOrCloseDoor = !openOrCloseDoor
        }
    }
    
    @IBAction func hideButtonTapped(_ sender: UIButton) {
        intercomImage.isHidden = hideOrNot ? true : false
        hideOrNot = !hideOrNot
    }
    
    @IBAction func upArrowButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func settingsButtonTapper(_ sender: UIButton) {
        
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - Private Methods
extension IntercomViewController {
    // Add shadow and borders for the bottom view
    private func configureShadowAndBorders(for: UIView) {
        self.bottomView.layer.masksToBounds = false
        self.bottomView.layer.shadowColor = UIColor.black.cgColor
        self.bottomView.layer.shadowOffset = CGSize(width: 0, height: -2)
        self.bottomView.layer.shadowRadius = 90
        self.bottomView.layer.shadowOpacity = 0.1
        
        self.bottomView.layer.borderWidth = 0.3
        self.bottomView.layer.borderColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.1).cgColor
    }
    
}
