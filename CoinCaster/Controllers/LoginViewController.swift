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
            
            let alert = UIAlertController(title: "Error", message: "Fields cannot be empty", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            present(alert, animated: true)
            
            return
        }
        
        coinManager.loginUser(email: email, password: password)
        
    }
    
}
