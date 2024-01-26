//
//  RegistrationViewController.swift
//  CoinCaster
//
//  Created by Onyi Esu on 21/01/2024.
//

import UIKit

class RegistrationViewController: UIViewController {
    
    var coinManager = CoinManager()
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var retypePasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let retypePassword = retypePasswordTextField.text, !retypePassword.isEmpty
        else{
            
            let alert = UIAlertController(title: "Error", message: "Fields cannot be empty", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            present(alert, animated: true)
            
            return
        }
        
        if password == retypePassword {
            
            coinManager.registerUser(email: email, password: password) { success in
                DispatchQueue.main.async {
                    if success {
                        // Perform the segue only if the registration was successful
                        self.performSegue(withIdentifier: segues.registerSegue, sender: self)
                    } else {
                        // Show an error message if registration failed
                        let alert = UIAlertController(title: "Registration Failed", message: "This email is already in use. Please use a different email", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            }
            
        } else {
            
            let alert = UIAlertController(title: "Error", message: "Passwords do not match", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default ) { _ in
                
                self.passwordTextField.text = ""
                
                self.retypePasswordTextField.text = ""
                
            })
                present(alert, animated: true)
        }
        
    }
    

}
