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
            alertPresenter.showAlert(withTitle: "Missing Information", message: "Please enter both email and password.")
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
                navigator.navigateToMainViewController()
            } else {
                alertPresenter.showAlert(withTitle: "Login Error", message: "Please try again.")
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
        alertPresenter.showAlert(withTitle: "Login Error", message: errorMessage)
    }
    
    
    private func navigateToMainViewController() {
        //Dismiss LoginViewController and embed ViewController in Navigation Controller
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let mainViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                let navigationController = UINavigationController(rootViewController: mainViewController)
                sceneDelegate.window?.rootViewController = navigationController
            }
        }
    }
    
    //helper function to present alert
    func showAlert(withTitle title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
