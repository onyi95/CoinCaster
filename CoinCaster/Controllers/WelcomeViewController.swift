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
        performSegue(withIdentifier: "showRegistration", sender: self)
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "showLogin", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRegistration",
           let registrationViewController = segue.destination as? RegistrationViewController {
            registrationViewController.coinManager = CoinManager.shared
        } else if segue.identifier == "showLogin",
                  let loginViewController = segue.destination as? LoginViewController {
            loginViewController.coinManager = CoinManager.shared
        }
    }
}
