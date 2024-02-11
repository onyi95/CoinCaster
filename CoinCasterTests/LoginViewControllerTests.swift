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

    override func setUp() {
        super.setUp()
        
        // Instantiate the LoginViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        XCTAssertNotNil(sut, "Failed to instantiate LoginViewController from storyboard")
        
        mockCoinManager = MockCoinManager()
        mockAlertPresenter = MockAlertPresenter()
        mockNavigator = MockNavigator()
        
        sut.coinManager = mockCoinManager
        sut.alertPresenter = mockAlertPresenter
        sut.navigator = mockNavigator
        
        sut.loadViewIfNeeded()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        mockCoinManager = nil
        mockAlertPresenter = nil
        mockNavigator = nil
        super.tearDown()
    }

    func testLoginPressed_WithValidCredentials_CallsLoginWithCorrectCredentials() {
        // Arrange
        let expectedEmail = "test@example.com"
        let expectedPassword = "password123"
        sut.emailTextField.text = expectedEmail
        sut.passwordTextField.text = expectedPassword
        
        // Act
        sut.loginPressed(UIButton())
        
        // Assert
        XCTAssertTrue(mockCoinManager.loginUserCalled)
        XCTAssertEqual(mockCoinManager.passedEmail, expectedEmail)
        XCTAssertEqual(mockCoinManager.passedPassword, expectedPassword)
    }
    
    func testConfigureTextFieldSecurity_SetsPasswordFieldToSecureEntry() {
        // This test assumes the `configureTextFieldSecurity` method is called within `viewDidLoad`.
        XCTAssertTrue(sut.passwordTextField.isSecureTextEntry, "Password text field should be set to secure text entry.")
    }

    // Test disabled due to difficulties in isolating Navigator components from UIKit dependencies.
    func testLoginPressed_WithLoginSuccess_NavigatesToCurrencySelectionViewController() {
        // Arrange
        sut.emailTextField.text = "test@example.com"
        sut.passwordTextField.text = "password123"
        let loginResult: Result<Int, LoginError> = .success(200)
        
        // Act
        mockCoinManager.loginCompletionResult?(loginResult)  // Simulate login result

        // Assert
        XCTAssertTrue(mockNavigator.navigateToCurrencySelectionViewControllerCalled)
    }
    // Test disabled due to difficulties in isolating AlertPresenter components from UIKit dependencies.
    func testLoginPressed_WithNetworkError_ShowsErrorMessage() {
        // Arrange
        let loginError: LoginError = .invalidCredentials
        let loginResult: Result<Int, LoginError> = .failure(loginError)
        
        // Act
        mockCoinManager.loginCompletionResult?(loginResult)
        
        
        // Assert
        XCTAssertTrue(mockAlertPresenter.showAlertCalled)
        XCTAssertEqual(mockAlertPresenter.lastTitle, "Login Error")
    }

    // Test disabled due to difficulties in isolating AlertPresenter components from UIKit dependencies.
    func testLoginPressed_WithEmptyFields_ShowsAlert() {
        // Arrange
        sut.emailTextField.text = ""
        sut.passwordTextField.text = ""
        
        // When
        sut.loginPressed(UIButton())
        
        // Then
        XCTAssertTrue(mockAlertPresenter.showAlertCalled, "Alert was not called when login was pressed with empty fields.")
        XCTAssertEqual(mockAlertPresenter.lastTitle, "Missing Information", "The alert title is not correct.")
        XCTAssertEqual(mockAlertPresenter.lastMessage, "Please enter both email and password.", "The alert message is not correct.")
    }
    

}
