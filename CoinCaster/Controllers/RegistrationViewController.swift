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

        // Do any additional setup after loading the view.
    }
    

    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        if ((passwordTextField.text?.isEmpty != nil) || (retypePasswordTextField.text?.isEmpty != nil))  && passwordTextField.text == retypePasswordTextField.text {
            
            //send user email and passowrd to the server
            coinManager.registerUser(email: emailTextField.text! , password: passwordTextField.text!)
            
        }else{
            
            //clear fields and tell the user that passwords dont match and ask to re-enter
        }
        
    }
    

}
