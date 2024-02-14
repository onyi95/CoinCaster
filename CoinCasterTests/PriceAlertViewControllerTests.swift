//
//  PriceAlertViewControllerTests.swift
//  CoinCasterTests
//
//  Created by Onyi Esu on 07/02/2024.
//

import XCTest
@testable import CoinCaster

final class PriceAlertViewControllerTests: XCTestCase {
    var sut: PriceAlertViewController!
    var mockCoinManager: MockCoinManager!
    var mockNotificationCenter: MockNotificationCenter!
    var mockAlertPresenter: MockAlertPresenter!

    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(identifier: "PriceAlertViewController") as? PriceAlertViewController
        mockCoinManager = MockCoinManager()
        mockNotificationCenter = MockNotificationCenter()
        mockAlertPresenter = MockAlertPresenter()
        
        sut.coinManager = mockCoinManager
        sut.notifications = mockNotificationCenter
        sut.alertPresenter = mockAlertPresenter
        
        sut.loadViewIfNeeded()
    }

    override func tearDown() {
        sut = nil
        mockCoinManager = nil
        mockNotificationCenter = nil
        mockAlertPresenter = nil
        super.tearDown()
    }

    func testStepperValueChanged_WhenValueIsChanged_PercentageTextFieldShowsSteppersValue() {
            // Arrange
            let expectedPercentageText = "10.0"
            let stepper = UIStepper()
            stepper.value = 10.0

            // Act
            sut.stepperValueChanged(stepper)

            // Assert
            XCTAssertEqual(sut.percentageTextField.text, expectedPercentageText, "Percentage text field should update to reflect stepper's value.")
        }
    
    func testNotificationButtonPressed_WithValidPercentage_TargetPriceSentToServer() {
        // Arrange
        sut.currentPrice = 100.0
        sut.percentageTextField.text = "10"

        // Act
        sut.notificationButtonPressed(UIButton())

        // Assert
        XCTAssertTrue(mockCoinManager.sendTargetPriceCalled, "sendTargetPriceToServer should be called when notification button is pressed with a valid percentage.")
        // Safely unwrap targetPriceSent before comparison, using a default value if nil
        let targetPriceSent = mockCoinManager.targetPriceSent ?? 0.0
        XCTAssertEqual(round(targetPriceSent * 100) / 100, 110.0, "Target price sent to server is not correctly calculated.")
    }
    
    func testNotificationButtonPressed_PermissionDenied_WillNotSendTargetPrice() {
        // Arrange
        sut.currentPrice = 100.0
        sut.percentageTextField.text = "10"
        mockNotificationCenter.permissionGranted = false

        // Act
        sut.notificationButtonPressed(UIButton())

        // Assert
        XCTAssertFalse(mockCoinManager.sendTargetPriceCalled, "Target price should not be sent if notification permission is denied.")
    }
    
    // Test disabled due to difficulties in isolating AlertPresenter components from UIKit dependencies.
    func testNotificationButtonPressed_InvalidPercentage_ShowsInvalidInputAlert() {
        // Arrange
        sut.percentageTextField.text = "Invalid" // Set invalid input to trigger alert

        // Act
        sut.notificationButtonPressed(UIButton())


        // Assert
        XCTAssertTrue(mockAlertPresenter.showAlertCalled)
        XCTAssertEqual(mockAlertPresenter.lastTitle, "Invalid")
        XCTAssertEqual(mockAlertPresenter.lastMessage, "Please enter a valid percentage.")
        }


    // Test disabled due to difficulties in isolating AlertPresenter components from UIKit dependencies.
    func testNotificationButtonPressed_WithoutCurrentPrice_ShowsInvalidInputAlert() {
        // Arrange
        sut.percentageTextField.text = "10"  // State Under Test: Percentage input without current price
        sut.currentPrice = nil
        
        // Act
        sut.notificationButtonPressed(UIButton())
        
  
        // Assert
        XCTAssertEqual(mockAlertPresenter.lastTitle, "Invalid")
        XCTAssertEqual(mockAlertPresenter.lastMessage, "Please select currency and enter a valid percentage.")
    }
    
    // Test disabled due to difficulties in isolating AlertPresenter components from UIKit dependencies.
    func testNotificationButtonPressed_PermissionDenied_ShowsAlert() {
        // Arrange
        sut.currentPrice = 100.0
        sut.percentageTextField.text = "10"
        mockNotificationCenter.permissionGranted = false
        

        // Act
        sut.notificationButtonPressed(UIButton())

        // Assert
        XCTAssertTrue(mockAlertPresenter.showAlertCalled, "An alert should be presented if notification permission is denied.")
    }
    
    // Test disabled due to difficulties in isolating AlertPresenter components from UIKit dependencies.
    func testMockAlertPresenter_ShouldSetPropertiesCorrectly() {
        // Arrange
        let expectedTitle = "Test Title"
        let expectedMessage = "Test Message"
        
        // Act
        mockAlertPresenter.showAlert(withTitle: expectedTitle, message: expectedMessage, onDismiss: nil)
        
        // Assert
        XCTAssertTrue(mockAlertPresenter.showAlertCalled, "showAlert was not called on the mock")
        XCTAssertEqual(mockAlertPresenter.lastTitle, expectedTitle, "Title did not match")
        XCTAssertEqual(mockAlertPresenter.lastMessage, expectedMessage, "Message did not match")
    }

    
}
