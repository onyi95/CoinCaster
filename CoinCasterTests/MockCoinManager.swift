//
//  MockCoinManager.swift
//  CoinCasterTests
//
//  Created by Onyi Esu on 05/02/2024.
//

import Foundation
@testable import CoinCaster
import UserNotifications

class MockCoinManager: CoinManagerProtocol {

    
    var registerUserCalled = false
    var loginUserCalled = false
    var passedEmail: String?
    var passedPassword: String?
    var registerCompletionResult: Result<Int, RegistrationError>!
    var loginCompletionResult: Result<Int, LoginError>!
    var updateCoinPriceCalled = false
    var lastCurrencyUsedForUpdate: String?
    var delegate: PriceUpdaterDelegate?
    var sendTargetPriceCalled = false
    var targetPriceSent: Double?
    var selectedCurrency: String?
    
    
    
    func registerUser(email: String, password: String, completion: @escaping (Result<Int, CoinCaster.RegistrationError>) -> Void) {
        registerUserCalled = true
        passedEmail = email
        passedPassword = password
        completion(registerCompletionResult)
    }
    
    func loginUser(email: String, password: String, completion: @escaping (Result<Int, CoinCaster.LoginError>) -> Void) {
        loginUserCalled = true
        passedEmail = email
        passedPassword = password
        completion(loginCompletionResult)
        }
    
    func updateCoinPrice(_ currency: String) {
        updateCoinPriceCalled = true
        lastCurrencyUsedForUpdate = currency
    }
    
    func sendTargetPriceToServer(targetPrice: Double) {
        sendTargetPriceCalled = true
        targetPriceSent = targetPrice
    }
    
    func userSelectedCurrency(currency: String) {
        selectedCurrency = currency
    }
}

class MockAlertPresenter: AlertPresenterProtocol {
    var lastTitle: String?
    var lastMessage: String?
    var showAlertCalled = false
    var isClearTextFields: Bool?
    var completion: (() -> Void)? // Added to handle asynchronous notification
    
    func showAlert(withTitle title: String, message: String, clearTextFields: Bool = false) {
        DispatchQueue.main.async {
            // Ensure async execution to mimic real-world conditions
            self.showAlertCalled = true
            self.lastTitle = title
            self.lastMessage = message
            self.completion?()
        }
    }
}

class MockNavigator: NavigatorProtocol {
    var navigateToCurrencySelectionViewControllerCalled = false
    
    func navigateToCurrencySelectionViewController() {
        navigateToCurrencySelectionViewControllerCalled = true
    }
}

class MockPriceUpdaterDelegate: PriceUpdaterDelegate {
    var didUpdatePriceCalled = false
     var lastPrice: String?
     var lastCurrency: String?
     var errorReceived: Error?

     func didUpdatePrice(price: String, currency: String) {
         didUpdatePriceCalled = true
//         DispatchQueue.main.async { //update the main thread
//             self.lastPrice = price
//             self.lastCurrency = currency
//         }

     }

     func didFailWithError(error: Error) {
         errorReceived = error
     }
}

class MockNotificationCenter: NotificationCenterProtocol {
    var authorizationRequested = false
    
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
        authorizationRequested = true
        completionHandler(true, nil)  // Simulate authorization granted
    }
}

