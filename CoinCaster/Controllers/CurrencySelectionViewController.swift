//
//  CurrencySelectionViewController.swift
//  CoinCaster
//
//  Created by Onyi Esu on 01/01/2024.
//

import UIKit
import KeychainSwift

class CurrencySelectionViewController: UIViewController {
    
    var coinManager: CoinManagerProtocol!
    var selectedCurrency: String?
    var currentPrice: Double?
    
    @IBOutlet weak var bitcoinLabel: UILabel!
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet weak var currencyLabel: UILabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the VC as the datasource and delegate for the picker
        currencyPicker.dataSource = self
        currencyPicker.delegate = self
        
        self.navigationController?.navigationBar.tintColor = UIColor.darkGray
        
        setupCoinManager()
    }
    
    private func setupCoinManager() {
        coinManager = CoinManager()
        coinManager?.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPriceAlert" {
            if let priceAlertViewController = segue.destination as? PriceAlertViewController {
                priceAlertViewController.recievedUserCurrency = selectedCurrency         //Property assignment to pass the selected currency to priceAlertViewController to then be sent to the backend for use in API call, when the user taps "Turn On Notifications"
                priceAlertViewController.coinManager = CoinManager()
                priceAlertViewController.currentPrice = currentPrice //Pass the current price for target price calculation
            }
        }
    }
    
    @IBAction func setPriceAlertPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "showPriceAlert", sender: self)
    }
}
    //MARK: - UIPickerView DataSource Methods
  
extension CurrencySelectionViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 //we only need one column of data in this context
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coinManager.currencyArray.count  //tell Xcode how many rows this picker should have
    }
}

    //MARK: - UIPickerView Delegate Methods
    // to be able to update the PickerView with some titles and detect when it is interacted with, setting up the PickerView’s delegate methods
    
extension CurrencySelectionViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return coinManager.currencyArray[row]
        //When the PickerView is loading up, it will ask its delegate for a row title and call the above method once for every row.
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedCurrency = coinManager.currencyArray[row]
        
        //passing the selected currency to CoinManager
        coinManager.updateCoinPrice(selectedCurrency)
        
        self.selectedCurrency = selectedCurrency
    }
}
    

//MARK: - CoinManager Delegate Methods

// Creating the delegate class
extension CurrencySelectionViewController: PriceUpdaterDelegate {
    func didUpdatePrice(price: String, currency: String) {
        DispatchQueue.main.async { //update the main thread
            self.bitcoinLabel.text = price
            self.currencyLabel.text = currency
            self.currentPrice = Double(price) // Update the current price when the price is fetched
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
//MARK: - Handle User Logout
extension CurrencySelectionViewController {
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        guard let user_id = KeychainSwift().get("userId") else {
            print("User ID not found")
            return
        }
        coinManager.logoutUser(withUserId: user_id) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.clearUserDataAndNavigateToAuthOptionsScreen()
                } else {
                    print("Couldn't log out. Try again")
                }
            }
        }
    }
    
    private func clearUserDataAndNavigateToAuthOptionsScreen() {
        // Clear user-specific information
        KeychainSwift().delete("token")
        KeychainSwift().delete("userId")
        
        //clear logged in state on device
        UserSessionManager.shared.logout()
        
        //Navigate back to the AuthOptions screen
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let authOptionsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AuthOptionsViewController") as? AuthOptionsViewController {
            sceneDelegate.window?.rootViewController = authOptionsViewController
        }
    }
}
