//
//  PriceAlertViewController.swift
//  CoinCaster
//
//  Created by Onyi Esu on 03/01/2024.
//

import UIKit
import UserNotifications

class PriceAlertViewController: UIViewController, UITextFieldDelegate {
    
    let coinManager = CoinManager()
    var recievedUserCurrency: String?
 
    @IBOutlet weak var percentageTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        percentageTextField.delegate = self
        
        // A tap gesture recogniser to dismiss the keyboard
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
        //Validate and convert the percentage text to a number
        guard let percentageString = percentageTextField.text,
              let percentage = Double(percentageString) else {
              print("Invalid percentage input")
              return
        }
        let targetPrice = calculateTargetPrice(percentage: percentage)
        coinManager.sendTargetPriceToServer(targetPrice: targetPrice)
        
        if let currency = recievedUserCurrency {
            print(currency)
            coinManager.userSelectedCurrency(currency: currency)
        }
        
            
        checkForPermission()
        
        
        
        
    }
    
 //MARK: - Calculate the Target Price to alert user on
    
    func calculateTargetPrice(percentage: Double) -> Double {
        
        let targetPrice = currentPrice! * (1 + (percentage/100))
        
            return targetPrice
    }
//MARK: - ????

//Request notification permissions
    func checkForPermission() {
        let notificationCenter = UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                self.dispatchNotification()
            }else if let error = error {
                print("Error requesting authorization: \(error)")
            }
        }
    }
    
//Create the notification content
    func dispatchNotification(){
        let content = UNMutableNotificationContent()
        content.title = "Price Alert"
        content.body = "Bitcoin has reached your target price of 'targetPrice'"
        content.sound = UNNotificationSound.default
    }
    
}
