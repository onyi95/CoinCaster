//
//  MockCoinManager.swift
//  CoinCasterTests
//
//  Created by Onyi Esu on 05/02/2024.
//

import Foundation
@testable import CoinCaster

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
}

class MockAlertPresenter: AlertPresenterProtocol {
    var lastTitle: String?
    var lastMessage: String?
    var showAlertCalled = false
    
    func showAlert(withTitle title: String, message: String) {
        showAlertCalled = true
        lastTitle = title
        lastMessage = message
    }
}

class MockNavigator: NavigatorProtocol {
    var navigationToMainViewControllerCalled = false
    
    func navigateToMainViewController() {
        navigationToMainViewControllerCalled = true
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
