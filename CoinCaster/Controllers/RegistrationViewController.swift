//
//  RegistrationViewController.swift
//  CoinCaster
//
//  Created by Onyi Esu on 21/01/2024.
//

import UIKit

class RegistrationViewController: UIViewController, NavigatorProtocol, AlertPresenterProtocol {
    
    var coinManager: CoinManagerProtocol! // Dependency Injection
    var alertPresenter: AlertPresenterProtocol!
    var navigator: NavigatorProtocol!
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypePasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFieldSecurity()
        self.navigator = self
        self.alertPresenter = self
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
            alertPresenter.showAlert(withTitle: "We need your details please", message: "Fields cannot be empty", clearTextFields: false)
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
            alertPresenter.showAlert(withTitle: "It's ok, we all make mistakes..", message: "Passwords do not match", clearTextFields: false)
                sender.isEnabled = true // Re-enable the button
        }
    }
    
    private func handleRegistrationResult(_ result: Result<Int, RegistrationError>) {
        switch result {
        case .success:
            navigator.navigateToCurrencySelectionViewController()
        case .failure(let error):
            let errorMessage = errorMessage(for: error)
            handleRegistrationError(error)
        }
    }

    func navigateToCurrencySelectionViewController() {
        //Dismiss RegistrationViewController and embed CurrencySelectionViewController in Navigation Controller
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let currencySelectionViewController = storyboard.instantiateViewController(withIdentifier: "CurrencySelectionViewController") as? CurrencySelectionViewController {
                let navigationController = UINavigationController(rootViewController: currencySelectionViewController)
                sceneDelegate.window?.rootViewController = navigationController
            }
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
        showAlert(withTitle: "Something went wrong..", message: errorMessage, clearTextFields: error == .emailAlreadyInUse)
    }

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
