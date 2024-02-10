//
//  LoginViewController.swift
//  CoinCaster
//
//  Created by Onyi Esu on 21/01/2024.
//

import UIKit

class LoginViewController: UIViewController {
    
    // Dependency Injection for better testability
    var coinManager: CoinManagerProtocol!
    var alertPresenter: AlertPresenterProtocol!
    var navigator: NavigatorProtocol!
    
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFieldSecurity()
        alertPresenter = AlertPresenter(viewController: self)
        navigator = Navigator(viewController: self)
    }
    
    private func configureTextFieldSecurity() {
        passwordTextField.isSecureTextEntry = true
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        attemptLogin()
    }
    
    private func attemptLogin(){
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            alertPresenter.showAlert(withTitle: "Missing Information", message: "Please enter both email and password.", onDismiss: nil)
            return
        }
        
        coinManager.loginUser(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleLoginResult(result)
            }
        }
    }
    
    private func handleLoginResult(_ result: Result<Int, LoginError>) {
        switch result {
        case .success(let statusCode):
            handleSuccess(statusCode: statusCode)
        case .failure(let loginError):
            handleLoginError(loginError)
        }
    }
    
    
    private func handleSuccess(statusCode: Int) {
            if statusCode == 200 {
                DispatchQueue.main.async {
                    self.navigator.navigateToCurrencySelectionViewController()
                }
            } else {
                alertPresenter.showAlert(withTitle: "Login Error", message: "Please try again.", onDismiss: nil)
            }
        }
    
    
    private func handleLoginError(_ error: LoginError) {
        let errorMessage: String
        switch error {
        case .networkError(let description):
            errorMessage = description
        case .invalidCredentials:
            errorMessage = "Invalid email or password. Please check your details or create account."
        case .other, .noData:
            errorMessage = "Login failed. Please try again later."
        }
        alertPresenter.showAlert(withTitle: "Login Error", message: errorMessage, onDismiss: nil)
    }
}
