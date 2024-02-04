//
//  ViewController.swift
//  CoinCaster
//
//  Created by Onyi Esu on 01/01/2024.
//

import UIKit
import KeychainSwift

class ViewController: UIViewController {
    
    var coinManager = CoinManager()
    var selectedCurrency: String?
    
    
    @IBOutlet weak var bitcoinLabel: UILabel!
    
    @IBOutlet weak var currencyPicker: UIPickerView!
    
    @IBOutlet weak var currencyLabel: UILabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //set the ViewController.swift as the datasource and delegate for the picker
        currencyPicker.dataSource = self
        currencyPicker.delegate = self
        coinManager.delegate = self   // 3*. the ViewController conforms to the                                                PriceUpdaterDelegate and implements the required methods by                             setting itself as the delegate of an
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPriceAlert" {
            if let priceAlertViewController = segue.destination as? PriceAlertViewController {
                priceAlertViewController.recievedUserCurrency = selectedCurrency
            }
        }
    }
    
    @IBAction func setPriceAlertPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showPriceAlert", sender: self)
    }
}
    //MARK: - UIPickerView DataSource Methods
  
extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 //we only need one column of data in this context
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coinManager.currencyArray.count  //tell Xcode how many rows this picker should
    }
}

    //MARK: - UIPickerView Delegate Methods
// to be able to update the PickerView with some titles and detect when it is interacted with we have to set up the PickerView’s delegate methods
    
    extension ViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return coinManager.currencyArray[row]
        //When the PickerView is loading up, it will ask its delegate for a row title and call the above method once for every row.
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedCurrency = coinManager.currencyArray[row]
        
        //passing the selected currency to CoinManager
        coinManager.updateCoinPrice(selectedCurrency)
        
        //Using Direct Property Assignment to pass the selected currency to priceAlertViewController to then be sent to the backend for use in API call, when the user taps the "Turn On Notifications Button"
        self.selectedCurrency = selectedCurrency

    }

}
    

//MARK: - CoinManager Delegate Methods

//2*. Creating the delegate class
extension ViewController: PriceUpdaterDelegate {
    
    func didUpdatePrice(price: String, currency: String) {
        
        DispatchQueue.main.async { //update the main thread
            self.bitcoinLabel.text = price
            self.currencyLabel.text = currency
        }
        
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
    
    //MARK: - Handle Useer Logout
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        if let user_id = KeychainSwift().get("userId"){
            CoinManager.shared.logoutUser(withUserId: user_id) { success in
                DispatchQueue.main.async {
                    if success {
                        // Clear user-specific information
                        KeychainSwift().delete("token")
                        KeychainSwift().delete("userId")
                        UserSessionManager.shared.logout() //clear logged in state on device
                        
                        //Navigate back to the welcome screen
                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            if let welcomeViewController = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController {
                                sceneDelegate.window?.rootViewController = welcomeViewController
                            }
                        }
                    } else {
                        print("Couldn't log out. Try again")
                    }
                }
            }
        } else {
            print("User ID not found")
        }
        
    }
    
}
