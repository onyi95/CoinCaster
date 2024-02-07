//
//  LoginViewControllerTests.swift
//  CoinCasterTests
//
//  Created by Onyi Esu on 06/02/2024.
//

import XCTest
@testable import CoinCaster

final class LoginViewControllerTests: XCTestCase {
    var sut: LoginViewController!
    var mockCoinManager: MockCoinManager!
    var mockAlertPresenter: MockAlertPresenter!
    var mockNavigator: MockNavigator!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Instantiate the LoginViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        XCTAssertNotNil(sut, "Failed to instantiate LoginViewController from storyboard")
        
        mockCoinManager = MockCoinManager()
        mockNavigator = MockNavigator()
        mockAlertPresenter = MockAlertPresenter()
        
        sut.coinManager = mockCoinManager
        sut.alertPresenter = mockAlertPresenter
        sut.navigator = mockNavigator
        
        
        _ = sut.view // Force view to load
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        mockCoinManager = nil
        mockAlertPresenter = nil
        mockNavigator = nil
        try super.tearDownWithError()
    }
    
    func testLoginPressed_WithEmptyFields_ShowsAlert() {
        // Given
        sut.emailTextField.text = ""
        sut.passwordTextField.text = ""
        
        // When
        sut.loginPressed(UIButton())
        
        // Then
        XCTAssertTrue(mockAlertPresenter.lastTitle == "Missing Information")
        XCTAssertTrue(mockAlertPresenter.lastMessage == "Please enter both email and password.")
    }

    func testLoginPressed_WithValidCredentials_CallsLoginWithCorrectCredentials() {
        // Given
        let expectedEmail = "test@example.com"
        let expectedPassword = "password123"
        sut.emailTextField.text = expectedEmail
        sut.passwordTextField.text = expectedPassword
        mockCoinManager.loginCompletionResult = .success(200) // Simulate successful login
        
        // When
        sut.loginPressed(UIButton())
        
        // Then
        XCTAssertTrue(mockCoinManager.loginUserCalled)
        XCTAssertEqual(mockCoinManager.passedEmail, expectedEmail)
        XCTAssertEqual(mockCoinManager.passedPassword, expectedPassword)
    }

    func testLoginPressed_WithLoginSuccess_NavigatesToCurrencySelectionViewController() {
        // Given
        sut.emailTextField.text = "test@example.com"
        sut.passwordTextField.text = "password123"
        mockCoinManager.loginCompletionResult = .success(200)
        
        // When
        sut.loginPressed(UIButton())
        
        // Allow the main queue to process pending tasks.
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        
        // Then
        XCTAssertTrue(mockNavigator.navigateToCurrencySelectionViewControllerCalled)
    }

    func testLoginPressed_WithNetworkError_ShowsErrorMessage() {
        // Given
        let errorDescription = "Check your connection."
        sut.emailTextField.text = "user@example.com"
        sut.passwordTextField.text = "password"
        mockCoinManager.loginCompletionResult = .failure(.networkError(errorDescription))
        
        // When
        sut.loginPressed(UIButton())
        
        // Allow the main queue to process pending tasks.
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        
        // Then
        XCTAssertEqual(mockAlertPresenter.lastTitle, "Login Error")
        XCTAssertEqual(mockAlertPresenter.lastMessage, errorDescription)
    }

    
    func testConfigureTextFieldSecurity_SetsPasswordFieldToSecureEntry() {
        // This test assumes the `configureTextFieldSecurity` method is called within `viewDidLoad`.
        XCTAssertTrue(sut.passwordTextField.isSecureTextEntry, "Password text field should be set to secure text entry.")
    }
    

}
