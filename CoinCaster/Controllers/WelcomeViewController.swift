//
//  WelcomeViewController.swift
//  CoinCaster
//
//  Created by Onyi Esu on 21/01/2024.
//

import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func createAccountPressed(_ sender: UIButton) {
        func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let registrationViewController = segue.destination as? RegistrationViewController {
                registrationViewController.coinManager = CoinManager() //Dependency Injection
            }
        }
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let loginViewController = segue.destination as? LoginViewController {
                loginViewController.coinManager = CoinManager()
            }
        }
    }
    
    
    

}
