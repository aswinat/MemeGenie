//
//  SignUpViewController.swift
//  MemeGenie
//
//  Created by Team6 on 10/10/19.
//  Copyright © 2019 Team6. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {


    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var errorTextField: UILabel!
    @IBOutlet weak var signUpTextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
        setUpElements()
        
        // listen for keyboard
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
                
            }
            
           
            
            deinit {
                //Stop listening for keyboard hide/show events
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            
        }
        // hide keyboard
        
        func hideKeyboard(){
           firstNameTextField.resignFirstResponder()
            
        }
        
        @objc func keyboardWillChange(notification: Notification){
            print("keyboard will show: \(notification.name.rawValue)")
           
           view.frame.origin.y = -75
            
        }
    
    
    func setUpElements() {
        // hide error label
        errorTextField.alpha = 0
        
        // style elements
        CustomTextField.styleTextField(firstNameTextField)
        CustomTextField.styleTextField(lastNameTextField)
        CustomTextField.styleTextField(emailTextField)
        CustomTextField.styleTextField(passwordTextField)
        CustomTextField.styleTextField(confirmPasswordTextField)
        
        CustomButton.styleButton(signUpTextButton)
    }
    
    // Check the fields and validate that data is correct.
    // Returns nil if all is correct.
    // Returns error message else.
    func validateFields() -> String? {
        // Check all fields are not empty
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        || lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        || emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        || confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
        }
        
        // Check if email is valid
        let cleanedEmail = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if credentialValidator.isEmailValid(cleanedEmail) == false {
            return "Please enter valid email address."
        }
        
        // Check if passwords match and are strong
        if passwordTextField.text! != confirmPasswordTextField.text! {
            return "Please make sure passwords match."
        }
        
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if credentialValidator.isPasswordValid(cleanedPassword) == false {
            return "Please make sure your password is at least 8 characters and contains 1 Uppercase Alphabet, 1 Lowercase Alphabet, 1 Number and 1 Special Character."
        }
        
        return nil
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        // validate fields
        let error = validateFields()
        
        if error != nil {
            showError(error!)
        } else {
            let firstname = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastname = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
//            Auth.auth().fetchSignInMethods(forEmail: email) { (user, error) in
//                //
//            }
            
            // create user
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                // Check for errors
                if err != nil {
                    self.showError("Error Creating User")
                    print(err?.localizedDescription ?? "Some error")
                } else {
                    let db = Firestore.firestore()
                    
                    db.collection("users").addDocument(data: ["first_name":firstname, "last_name":lastname, "uid":result!.user.uid], completion: { (error) in
                        if error != nil {
                            self.showError("Error saving data")
                        }
                    })
                }
            }
            // transition to home or tab bar controller
            self.transitionToHome()
        }
        hideKeyboard()
    }
    
    func showError(_ message:String) {
        errorTextField.text = message
        errorTextField.alpha = 1
    }
    
    func transitionToHome() {
        let homeViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? HomeViewController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
}
