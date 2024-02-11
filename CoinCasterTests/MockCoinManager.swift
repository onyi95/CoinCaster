//
//  MockCoinManager.swift
//  CoinCasterTests
//
//  Created by Onyi Esu on 05/02/2024.
//

import Foundation
@testable import CoinCaster
import UserNotifications
import UIKit

class MockCoinManager: CoinManagerProtocol {
    var currencyArray: [String] = ["AUD"]
    var registerUserCalled = false
    var loginUserCalled = false
    var logoutUserCalled = false
    var passedEmail: String?
    var passedPassword: String?
    var registerCompletionResult: Result<Int, RegistrationError>!
    var loginCompletionResult: ((Result<Int, LoginError>) -> Void)?
    var updateCoinPriceCalled = false
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
        loginCompletionResult = completion
    }
    
    func updateCoinPrice(_ currency: String) {
        updateCoinPriceCalled = true
        selectedCurrency = currency
        
        //Simulate the price update
        delegate?.didUpdatePrice(price: "12345", currency: currency)
    }
    
    func sendTargetPriceToServer(targetPrice: Double) {
        sendTargetPriceCalled = true
        targetPriceSent = targetPrice
    }
    
    func userSelectedCurrency(currency: String) {
        selectedCurrency = currency
    }
    
    func logoutUser(withUserId userId: String, completion: @escaping (Bool) -> Void) {
        logoutUserCalled = true
        completion(true)
    }
}

class MockAlertPresenter: AlertPresenterProtocol {
    var lastTitle: String?
    var lastMessage: String?
    var showAlertCalled = false
    
    func showAlert(withTitle title: String, message: String, onDismiss: (() -> Void)? = nil) {
            self.showAlertCalled = true
            self.lastTitle = title
            self.lastMessage = message
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
            lastPrice = price
            lastCurrency = currency
        }
        
        func didFailWithError(error: Error) {
            errorReceived = error
        }
    }
    
    class MockNotificationCenter: NotificationCenterProtocol {
        var permissionGranted: Bool?
        
        func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
            completionHandler(permissionGranted ?? false, nil)  // Simulate authorization granted
        }
    }
    

