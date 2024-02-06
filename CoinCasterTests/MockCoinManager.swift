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
    }

class MockAlertPresenter: AlertPresenterProtocol {
    var lastTitle: String?
    var lastMessage: String?
    
    func showAlert(withTitle title: String, message: String) {
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
