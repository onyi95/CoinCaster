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
            
            let alert = UIAlertController(title: "We need your details please", message: "Fields cannot be empty", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            present(alert, animated: true)
            
            return
        }
        
        if password == retypePassword {
            coinManager.registerUser(email: email, password: password) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let statusCode):
                        if statusCode == 201 {
                            self.performSegue(withIdentifier: segues.registerSegue, sender: self)
                        }
                    case .failure(let registrationError):
                        var errorMessage = "An unexpected error occurred. Please try again."
                        switch registrationError {
                        case .networkError(let description):
                            errorMessage = description
                            self.showAlert(withTitle: "Error", message: errorMessage)
                        case .emailAlreadyInUse:
                            errorMessage = "Email already registered. Please log in."
                            self.showAlert(withTitle: "Already Registered?", message: errorMessage)
                        case .other:
                            errorMessage = "Failed to register user. Please try again."
                            self.showAlert(withTitle: "Something went wrong..", message: errorMessage)
                        case .noData:
                            errorMessage = "Failed to Register user. Please try again."
                            self.showAlert(withTitle: "Something went wrong..", message: errorMessage)
                        }
                    }
                }
            }
            
        } else {
            
            let alert = UIAlertController(title: "It's ok, we all make mistakes..", message: "Passwords do not match", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default ) { _ in
                
                self.passwordTextField.text = ""
                
                self.retypePasswordTextField.text = ""
                
            })
                present(alert, animated: true)
        }
        
    }

    // Helper function to present alerts
    func showAlert(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.passwordTextField.text = ""
            self.retypePasswordTextField.text = ""
        })
        self.present(alert, animated: true)
    }

}
