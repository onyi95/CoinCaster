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
    
    func sendTargetPriceToServer(targetPrice: Double, completion: @escaping (Bool) -> Void) {
        sendTargetPriceCalled = true
        targetPriceSent = targetPrice
    }
    
    func userSelectedCurrency(currency: String, completion: @escaping (Bool) -> Void) {
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
    var didFailWithErrorCalled = false
    var lastPrice: String?
    var lastCurrency: String?
    var errorReceived: Error?
    var updatePriceCompletion: ((String, String) -> Void)?
    var failureCompletion: ((Error) -> Void)?
        
    func didUpdatePrice(price: String, currency: String) {
        didUpdatePriceCalled = true
        lastPrice = price
        lastCurrency = currency
        // Call the completion handler when the delegate method is triggered
        updatePriceCompletion?(price, currency)
        //failureCompletion:
        
    }
        
    func didFailWithError(error: Error) {
        didFailWithErrorCalled = true
        errorReceived = error
    }
}
    
class MockNotificationCenter: NotificationCenterProtocol {
    var permissionGranted: Bool?
        
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
        completionHandler(permissionGranted ?? false, nil)  // Simulate authorization granted
    }
}

class MockURLSession: URLSessionProtocol {
    var lastURL: URL?
    private let mockTask: MockTask
    var nextData: Data?
    var nextResponse: URLResponse?
    var nextError: Error?
    var lastRequest: URLRequest?
    var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
    
    init(data: Data?, urlResponse: URLResponse?, error: Error?) {
        mockTask = MockTask(data: data, urlResponse: urlResponse, error: error)
        self.nextData = data
        self.nextResponse = urlResponse
        self.nextError = error
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> CoinCaster.URLSessionDataTaskProtocol {
         lastURL = request.url
         lastRequest = request
         mockTask.completionHandler = completionHandler
         return mockTask
    }
    
    func triggerCompletion(data: Data?, response: URLResponse?, error: Error?) {
        completionHandler?(data, response, error)
    }
}

class MockTask: URLSessionDataTaskProtocol {
        private let data: Data?
        private let urlResponse: URLResponse?
        private let mockError: Error?
        
        var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
        
        init(data: Data?, urlResponse: URLResponse?, error: Error?) {
            self.data = data
            self.urlResponse = urlResponse
            self.mockError = error
        }
        
        func resume() {
            completionHandler?(data, urlResponse, mockError)
        }
}

    

