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
        //Enhance security for user's data
        passwordTextField.isSecureTextEntry = true
        retypePasswordTextField.isSecureTextEntry = true
    }
    

    @IBAction func registerButtonPressed(_ sender: UIButton) {
        sender.isEnabled = false // Disable the button to prevent multiple taps
        
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let retypePassword = retypePasswordTextField.text, !retypePassword.isEmpty else {
            showAlert(withTitle: "We need your details please", message: "Fields cannot be empty")
            sender.isEnabled = true // Re-enable the button before return
            return
        }
        if password == retypePassword {
            //Attempt to register the user on the backend
            coinManager.registerUser(email: email, password: password) { [weak self] result in
                guard let self = self else { return } //Weak self capture used in the closure to avoid strong reference cycles
                DispatchQueue.main.async {
                    sender.isEnabled = true // Re-enable the button
                    switch result {
                    case .success(let statusCode):
                        if statusCode == 201 {
                            self.navigateToMainViewController()
                        } else {
                            self.showAlert(withTitle: "Registration Error", message: "Please try again.")
                        }
                    case .failure(let registrationError):
                        self.handleRegistrationError(registrationError)
                    }
                }
            }
        } else {
            showAlert(withTitle: "It's ok, we all make mistakes..", message: "Passwords do not match", clearTextFields: true)
        }
    }

    private func navigateToMainViewController() {
        //Dismiss RegistrationViewController and embed ViewController in Navigation Controller
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let mainViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                let navigationController = UINavigationController(rootViewController: mainViewController)
                sceneDelegate.window?.rootViewController = navigationController
            }
        }
    }
    
    private func handleRegistrationError(_ error: RegistrationError){
        var errorMessage = "An unexpected error occurred. Please try again."
        switch error {
        case .networkError(let description):
            errorMessage = description
        case .emailAlreadyInUse:
            errorMessage = "Email already in use. Please log in."
        case .other:
            errorMessage = "Failed to register user. Please try again."
        case .noData:
            errorMessage = "Failed to Register user. Please try again."
        }
        showAlert(withTitle: "Something went wrong..", message: errorMessage, clearTextFields: error == .emailAlreadyInUse)
    }

    // Helper function to present alerts
    func showAlert(withTitle title: String, message: String, clearTextFields: Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            if clearTextFields {
                self.passwordTextField.text = ""
                self.retypePasswordTextField.text = ""
            }
        })
        self.present(alert, animated: true)
    }

}
