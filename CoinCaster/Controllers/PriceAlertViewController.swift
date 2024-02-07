//
//  PriceAlertViewController.swift
//  CoinCaster
//
//  Created by Onyi Esu on 03/01/2024.
//

import UIKit
import UserNotifications

class PriceAlertViewController: UIViewController, UITextFieldDelegate, AlertPresenterProtocol {
    
    var coinManager: CoinManagerProtocol!
    var notifications: NotificationCenterProtocol!
    var alertPresenter: AlertPresenterProtocol!
    var currentPrice: Double?
    var recievedUserCurrency: String?
 
    @IBOutlet weak var percentageTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        percentageTextField.delegate = self
        self.alertPresenter = self
        setupTapGesture()
        self.navigationController?.navigationBar.tintColor = UIColor.darkGray
    }
    
    private func setupTapGesture() {    // A tap gesture recogniser to dismiss the keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        percentageTextField.text = String(format: "%.1f", sender.value)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() //Dismiss the keyboard
        return true
    }
    
    @IBAction func notificationButtonPressed(_ sender: UIButton) {
        print("notificationButtonPressed triggered")
        //Validate and convert the percentage text to a number
        guard let percentageString = percentageTextField.text,
              let percentage = Double(percentageString),
              let currentPrice = currentPrice else {
            alertPresenter.showAlert(withTitle: "Invalid", message: "Please select currency and enter a valid percentage.", clearTextFields: false)
            return
        }

        let targetPrice = calculateTargetPrice(percentage: percentage, basedOn: currentPrice)
        coinManager.sendTargetPriceToServer(targetPrice: targetPrice)
        
        if let currency = recievedUserCurrency {
            //print(currency)
            coinManager.userSelectedCurrency(currency: currency)
        }
        checkForPermission()
    }
    
 //MARK: - Calculate the Target Price to alert user on
    private func calculateTargetPrice(percentage: Double, basedOn currentPrice: Double) -> Double {
        return currentPrice * (1 + (percentage / 100))
    }
    
//MARK: - Request Notification Permissions
    private func checkForPermission() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                if granted {
                    print("Access granted")
                } else if let error = error {
                    print("Error requesting authorization: \(error)")
                }
            }
        }

   func showAlert(withTitle title: String, message: String, clearTextFields: Bool = false) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
}
