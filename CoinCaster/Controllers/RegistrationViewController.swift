//
//  RegistrationViewController.swift
//  CoinCaster
//
//  Created by Onyi Esu on 21/01/2024.
//

import UIKit

class RegistrationViewController: UIViewController {
    
    var coinManager: CoinManagerProtocol!
    var alertPresenter: AlertPresenterProtocol!
    var navigator: NavigatorProtocol!
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypePasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFieldSecurity()
        alertPresenter = AlertPresenter(viewController: self)
        navigator = Navigator(viewController: self)
    }
    
    private func configureTextFieldSecurity() {             //Enhance security for user's data
        passwordTextField.isSecureTextEntry = true
        retypePasswordTextField.isSecureTextEntry = true
    }

    @IBAction func registerButtonPressed(_ sender: UIButton) {
        sender.isEnabled = false // Disable the button to prevent multiple taps
        
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let retypePassword = retypePasswordTextField.text, !retypePassword.isEmpty else {
            alertPresenter.showAlert(withTitle: "We need your details please", message: "Fields cannot be empty", onDismiss: nil)
            sender.isEnabled = true // Re-enable the button before return
            return
        }
        if password == retypePassword {
            //Attempt to register the user on the backend
            coinManager.registerUser(email: email, password: password) { [weak self] result in
                guard let self = self else { return } //Weak self capture used in the closure to avoid strong reference cycles
                DispatchQueue.main.async {
                    sender.isEnabled = true // Re-enable the button
                    self.handleRegistrationResult(result)
                }
            }
        } else {
            alertPresenter.showAlert(withTitle: "It's ok, we all make mistakes..", message: "Passwords do not match", onDismiss: nil)
                sender.isEnabled = true // Re-enable the button
        }
    }
    
    private func handleRegistrationResult(_ result: Result<Int, RegistrationError>) {
        switch result {
        case .success:
            navigator.navigateToCurrencySelectionViewController()
        case .failure(let error):
            _ = errorMessage(for: error)
            handleRegistrationError(error)
        }
    }
    func errorMessage(for error: RegistrationError) -> String { //separate message determination for testability
        switch error {
        case .networkError(let description):
            return description
        case .emailAlreadyInUse:
            return "Email already in use. Please log in."
        case .other:
            return "Failed to register user. Please try again."
        case .noData:
            return "Failed to Register user. Please try again."
        }
    }
    
    func handleRegistrationError(_ error: RegistrationError) {
        let errorMessage = self.errorMessage(for: error)
        alertPresenter.showAlert(withTitle: "Something went wrong..", message: errorMessage, onDismiss:{
            if error == .emailAlreadyInUse {
                self.passwordTextField.text = ""
                self.retypePasswordTextField.text = ""
            }
        } )
    }
}
