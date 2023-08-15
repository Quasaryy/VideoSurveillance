//
//  EditViewController.swift
//  VideoSurveillance
//
//  Created by Yury on 14/08/2023.
//

import UIKit
import RealmSwift

class EditViewController: UIViewController {
    
    // MARK: - Properties
    var idOfDoor: Int!
    
    // MARK: IB Outlets
    @IBOutlet weak var editDoorNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Background color main screen
        view.backgroundColor = .systemGray6
        
        
        // Updating save button state
        updateSaveButton()
    }

    // MARK: IB Actions
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // Enable save button if text field are not empty and has been edited
    @IBAction func editDoorNameTextFieldChanged(_ sender: UITextField) {
        updateSaveButton()
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }

}


// MARK: Private Methods
extension EditViewController {
    // Enable save button if text field are not empty
    private func updateSaveButton() {
        let textField = editDoorNameTextField.text ?? ""
        saveButton.isEnabled = !textField.isEmpty
    }
    
}

// Hiding keyword
extension EditViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}
