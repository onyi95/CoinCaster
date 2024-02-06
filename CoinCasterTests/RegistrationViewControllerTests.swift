//
//  RegistrationViewControllerTests.swift
//  CoinCasterTests
//
//  Created by Onyi Esu on 05/02/2024.
//

import XCTest
@testable import CoinCaster

final class RegistrationViewControllerTests: XCTestCase {
    var sut: RegistrationViewController!
    var mockCoinManager: MockCoinManager!
    var mockAlertPresenter: MockAlertPresenter!
    var mockNavigator: MockNavigator!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        // Instantiate the RegistrationViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "RegistrationViewController") as? RegistrationViewController
        XCTAssertNotNil(sut, "Failed to instantiate RegistrationViewController from storyboard")
        
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
        super.tearDown()
    }

    func testRegisterUser_WithValidInput_CallsRegisterUserOnCoinManager() {
        //Given
        let expectedEmail = "test@example.com"
        let expectedPassword = "password123"
        
        mockCoinManager.registerCompletionResult = .success(201)
        
        //When
        sut.emailTextField.text = expectedEmail
        sut.passwordTextField.text = expectedPassword
        sut.retypePasswordTextField.text = expectedPassword
        sut.registerButtonPressed(UIButton())
        
        //Then
        XCTAssertTrue(mockCoinManager.registerUserCalled, "registerUser was not called on the coinManager")
        XCTAssertEqual(mockCoinManager.passedEmail, expectedEmail,"Passed email is not correct")
        XCTAssertEqual(mockCoinManager.passedPassword, expectedPassword, "Passed password is not correct")
    }
    
    func testRegisterUser_WithEmptyFields_DoesNotCallRegisterUser() {
        //Given
        sut.emailTextField.text = ""
        sut.passwordTextField.text = ""
        sut.retypePasswordTextField.text = ""
        
        //When
        sut.registerButtonPressed(UIButton())
        
        //Then
        XCTAssertFalse(mockCoinManager.registerUserCalled, "registerUser should not be called when any field is empty.")
    }
    
    func testRegisterUser_WithPasswordMismatch_DoesNotCallRegisterUser() {
        //Given
        sut.emailTextField.text = "test@example.com"
        sut.passwordTextField.text = "pasword123"
        sut.retypePasswordTextField.text = "123456"
        
        //When
        sut.registerButtonPressed(UIButton())
        
        //Then
        XCTAssertFalse(mockCoinManager.registerUserCalled, "registerUser should not be called when passwords do not match.")
    }
    
    func testRegisterUser_WhenEmailAlreadyInUse_HandlesErrorCorrectly() {
        //Given
        sut.emailTextField.text = "test@case.com"
        sut.passwordTextField.text = "password789"
        sut.retypePasswordTextField.text = "password123"
        mockCoinManager.registerCompletionResult = .failure(.emailAlreadyInUse)
        
        //When
        sut.registerButtonPressed(UIButton())
        
        //Then
        XCTAssertFalse(mockCoinManager.registerUserCalled, "registerUser should not be called when the email provided is already in use.")
    }
    

    func test_handleRegistrationError_NetworkError_ShowsCorrectErrorMessage() {
        //Given
        let error: RegistrationError = .networkError("Network connection lost")
        
        //When
        sut.handleRegistrationError(error)
        
        //Then
        XCTAssertEqual(sut.errorMessage(for: error), "Network connection lost")
    }

    func test_handleRegistrationError_EmailAlreadyInUse_ShowsCorrectErrorMessage() {
        //Given
        let error: RegistrationError = .emailAlreadyInUse
        
        //When
        sut.handleRegistrationError(error)
        
        //Then
        XCTAssertEqual(sut.errorMessage(for: error), "Email already in use. Please log in.")
    }

    func test_handleRegistrationError_OtherError_ShowsCorrectErrorMessage() {
        //Given
        let error: RegistrationError = .other(0)
        
        //When
        sut.handleRegistrationError(error)
        
        //Then
        XCTAssertEqual(sut.errorMessage(for: error), "Failed to register user. Please try again.")
    }

    func test_handleRegistrationError_NoDataError_ShowsCorrectErrorMessage() {
        //Given
        let error: RegistrationError = .noData

        //When
        sut.handleRegistrationError(error)
        
        //Then
        XCTAssertEqual(sut.errorMessage(for: error), "Failed to Register user. Please try again.")
    }


}
