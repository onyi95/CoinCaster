//
//  PriceAlertViewController.swift
//  CoinCaster
//
//  Created by Onyi Esu on 03/01/2024.
//

import UIKit
import UserNotifications

class PriceAlertViewController: UIViewController {
    
    @IBOutlet weak var percentageValue: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        percentageValue.text = String(format: "%.5f", sender.value)
    }
    
    @IBAction func notificationButtonPressed(_ sender: UIButton) {
        //Validate and convert the percentage text to a number
        guard let percentageString = percentageValue.text,
              let percentage = Double(percentageString),
              percentage > 0 else {
              print("Invalid percentage input")
              return
        }
        checkForPermission()
        
        
    }
    
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
