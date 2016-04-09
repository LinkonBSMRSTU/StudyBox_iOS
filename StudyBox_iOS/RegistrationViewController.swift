//
//  RegistrationViewController.swift
//  StudyBox_iOS
//
//  Created by Kacper Cz on 28.02.2016.
//  Copyright © 2016 BLStream. All rights reserved.
//

import UIKit
import Foundation
import Reachability

var userDataForRegistration = [String : String]()

class RegistrationViewController: UserViewController, InputViewControllerDataSource {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var inputViews = [UITextField]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* the login button is by default disabled,
         user has to enter some data and it has to be verified
         */
        
        if !isConnectedToInternet() {
            showAlert(.NoInternet)
        }
        
        disableRegisterButton()
        registerButton.layer.cornerRadius = 10.0
        
        inputViews.append(emailTextField)
        inputViews.append(passwordTextField)
        inputViews.append(repeatPasswordTextField)
        
        emailTextField.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
        passwordTextField.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
        repeatPasswordTextField.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
        registerButton.titleLabel?.font = UIFont.sbFont(size: sbFontSizeMedium, bold: false)
    }
    
    func isConnectedToInternet() -> Bool {
        //returns true if connected, false if disconnected
        let reachability = Reachability.reachabilityForInternetConnection()
        
        if reachability.currentReachabilityStatus() == .NotReachable {
            return false
        } else {
            return true
        }
    }
    
    func checkEmail(textField: UITextField) -> () {
        if let text = textField.text where textField == emailTextField {
            
            textField.text = text.trimWhiteCharacters()
            
            if let text = textField.text {
                if !text.isValidEmail() {
                    showAlert(.EmailIncorrect)

                }
            }
        }
    }
    
    func checkPasswordLengthAndSpaces(password: UITextField) {
        if let characterCount = password.text?.characters.count {
            if characterCount < 8 && characterCount != 0 {
                showAlert(.PasswordTooShort)
                //To prevent popping up multiple error alerts
                repeatPasswordTextField.resignFirstResponder()
            }
        }
        if password.text?.containsString(" ") == true {
            showAlert(.PasswordContainsSpace)
            repeatPasswordTextField.resignFirstResponder()
        }
    }
    
    func checkPasswordsMatch(password1 password1: UITextField, password2: UITextField) {
        
        if password1.text != "" && password2.text != "" {
            if password1.text != password2.text {
                password1.textColor = UIColor.sb_Raspberry()
                password2.textColor = UIColor.sb_Raspberry()
                showAlert(.PasswordsDontMatch)
                disableRegisterButton()
            } else {
                password1.textColor = UIColor.sb_DarkBlue()
                password2.textColor = UIColor.sb_DarkBlue()
                
                enableRegisterButton()
            }
        } else {
            disableRegisterButton()
        }
    }
    
    func textFieldDidEndEditing(editedTextField: UITextField) {
        
        switch editedTextField {
            
        case emailTextField:
            checkEmail(editedTextField)
            checkPasswordsMatch(password1: passwordTextField, password2: repeatPasswordTextField)
            
        case passwordTextField:
            checkPasswordLengthAndSpaces(passwordTextField)
            
        case repeatPasswordTextField:
            checkPasswordsMatch(password1: passwordTextField, password2: repeatPasswordTextField)
            
        default:
            return
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        let nextTag = textField.tag + 1
        
        // Try to find next responder
        let nextResponder = textField.superview?.viewWithTag(nextTag) as UIResponder!
        
        if nextResponder != nil {
            // Found next responder, so set it.
            nextResponder?.becomeFirstResponder()
        } else
        {
            // Not found, so hide keyboard
            textField.resignFirstResponder()
        }
        return false
    }
    
    @IBAction func cancelRegistration(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func register(sender: UIButton) {
        
        let areTextFieldsNotEmpty = emailTextField.text != "" && passwordTextField.text != "" && repeatPasswordTextField.text != ""
        
        if areTextFieldsNotEmpty && isConnectedToInternet() {
            userDataForRegistration["email"] = emailTextField.text
            userDataForRegistration["password"] = repeatPasswordTextField.text
            
            //TODOs: pass over the dictionary with data
            dismissViewControllerAnimated(true) {[unowned self] () -> Void in
                self.successfulLoginTransition() }
        } else if !areTextFieldsNotEmpty {
            showAlert(.FieldsNotEmpty)
        } else if !isConnectedToInternet() {
            showAlert(.NoInternet)
        }
    }
    
    func disableRegisterButton() {
        registerButton.backgroundColor = UIColor.grayColor()
        registerButton.enabled = false
    }
    
    func enableRegisterButton() {
        registerButton.backgroundColor = UIColor.sb_Raspberry()
        registerButton.enabled = true
    }
    
    enum AlertType {
        case PasswordTooShort
        case PasswordsDontMatch
        case EmailIsTaken
        case PasswordContainsSpace
        case NoInternet
        case EmailIncorrect
        case FieldsNotEmpty
    }
    
    let alertMessagesDict: [AlertType : (String, String)] = [
        .NoInternet : ("Brak połączenia", "Nie można połączyć się z Internetem. Sprawdź połączenie"),
        .EmailIsTaken : ("Adres e-mail zajęty", "Już istnieje konto z takim adresem e-mail."),
        .PasswordContainsSpace : ("Spacja w haśle", "Hasło nie może zawierać spacji."),
        .EmailIncorrect : ("Niepoprawny adres e-mail", "Adres e-mail zawiera spację lub jest w złym formacie."),
        .PasswordsDontMatch : ("Hasła są różne", "Oba hasła muszą być identyczne."),
        .PasswordTooShort : ("Za krótkie hasło", "Hasło musi mieć co najmniej 8 znaków."),
        .FieldsNotEmpty : ("Wypełnij pola", "Sprawdź czy wszystkie pola formularza są wypełnione.")
    ]
    
    func showAlert(type: AlertType) {
        
        let alertController = UIAlertController(title: alertMessagesDict[type]!.0,
                                                message: alertMessagesDict[type]!.1,
                                                preferredStyle: .Alert)
        
        let actionOk = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(actionOk)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}
