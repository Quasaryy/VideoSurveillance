//
//  EditViewController.swift
//  VideoSurveillance
//
//  Created by Yury on 14/08/2023.
//

import UIKit
import RealmSwift

class EditViewController: UIViewController {
    
    // MARK: IB Outlets
    
    @IBOutlet weak var editDoorNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Properties
    
    var doorId: Int?
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup UI
        UIManager.shared.setupUIForEditScreen(editDoorNameTextField: self.editDoorNameTextField, saveButton: self.saveButton, editController: self)
        
    }
    
    // MARK: IB Actions
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    // Enable save button if text field are not empty and has been edited
    @IBAction func editDoorNameTextFieldChanged(_ sender: UITextField) {
        UtilityManager.shared.updateSaveButton(editDoorNameTextField: editDoorNameTextField, saveButton: saveButton)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}

// MARK: Text field delegate

// Hiding keyword
extension EditViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}
