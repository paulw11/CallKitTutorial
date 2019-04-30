//
//  AddEditViewController.swift
//  CallKitTutorial
//
//  Created by Paul Wilkinson on 27/2/19.
//  Copyright © 2019 Paul Wilkinson. All rights reserved.
//

import UIKit
import CallerData

class AddEditViewController: UIViewController {
    
    @IBOutlet weak var callerName: UITextField!
    @IBOutlet weak var callerNumber: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var caller: Caller? {
        didSet {
            self.updateUI()
        }
    }
    
    var callerData: CallerData!
    var isBlocked = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.callerName.delegate = self
        self.callerNumber.delegate = self
        self.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUI()
    }
    
    private func updateUI() {
        
        guard let caller = self.caller,
            let callerName = self.callerName,
            let callerNumber = self.callerNumber else {
                return
        }
        
        callerName.text = caller.name
        callerNumber.text = caller.number != 0 ? String(caller.number):""
        self.navigationItem.title = caller.name
        
        self.updateSaveButton()
        
    }
    
    private func updateSaveButton() {
        self.saveButton.isEnabled = false
        guard let name = self.callerName.text,
            let number = self.callerNumber.text else {
                return
        }
        self.saveButton.isEnabled = !(name.isEmpty || number.isEmpty)
    }
    
    @IBAction func textChanged(_ sender: UITextField) {
        self.updateSaveButton()
    }

    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        if let numberText = self.callerNumber.text,
            let number = Int64(numberText)  {
            
            let caller = self.caller ?? Caller(context: self.callerData.context)
            caller.name = self.callerName.text
            caller.number  = number
            caller.isBlocked = self.isBlocked
            caller.isRemoved = false
            caller.updatedDate = Date()
            self.callerData.saveContext()
        }
        
        self.performSegue(withIdentifier: "unwindFromSave", sender: self)
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

extension AddEditViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text,
            let textRange = Range(range, in: text) else {
                return false
        }
        
        let updatedText = text.replacingCharacters(in: textRange,
                                                   with: string)
        if textField == self.callerNumber {
            if updatedText.isEmpty {
                return true
            }
            if Int64(updatedText) == nil {
                return false
            }
        } else if textField == self.callerName {
            self.navigationItem.title = updatedText
        }
        return true
    }
    
}
