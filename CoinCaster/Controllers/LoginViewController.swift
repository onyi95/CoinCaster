//
//  LoginViewController.swift
//  CoinCaster
//
//  Created by Onyi Esu on 21/01/2024.
//

import UIKit

class LoginViewController: UIViewController {
    
    var coinManager = CoinManager()
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty

        else {
            
            let alert = UIAlertController(title: "We need your details please", message: "Fields cannot be empty", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            present(alert, animated: true)
            
            return
        }
        
        coinManager.loginUser(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let statusCode):
                    if statusCode == 200 {
                        self.performSegue(withIdentifier: segues.loginSegue, sender: self)
                    }
                case .failure(let loginError):
                    var errorMessage = "An unexpected error occurred. Please try again."
                    switch loginError {
                    case .networkError(let description):
                        errorMessage = description
                        self.showAlert(withTitle: "Error", message: errorMessage)
                    case .invalidCredentials:
                        errorMessage = "Invalid email or password. Please enter correct details or register."
                        self.showAlert(withTitle: "Have you registered?", message: errorMessage)
                    case .other:
                        errorMessage = "Login failed. Please try again."
                        self.showAlert(withTitle: "Something went wrong..", message: errorMessage)
                    case .noData:
                        errorMessage = "Login failed. Please try again."
                        self.showAlert(withTitle: "Something went wrong..", message: errorMessage)
                    }
                }
            }
        }
        
        
    }
    //helper function to present alert
    func showAlert(withTitle title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
        })
        self.present(alert, animated: true)
    }
}
