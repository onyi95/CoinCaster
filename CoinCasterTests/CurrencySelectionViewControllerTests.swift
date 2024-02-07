//
//  CurrencySelectionViewControllerTests.swift
//  CoinCasterTests
//
//  Created by Onyi Esu on 06/02/2024.
//

import XCTest
@testable import CoinCaster

final class CurrencySelectionViewControllerTests: XCTestCase {
    var sut: CurrencySelectionViewController!
    var mockCoinManager: MockCoinManager!
    var mockDelegate: MockPriceUpdaterDelegate!
    
    override func setUpWithError() throws {
        super.setUp()
        
        // Instantiate the CurrencySelectionViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "CurrencySelectionViewController") as? CurrencySelectionViewController
        XCTAssertNotNil(sut, "Failed to instantiate CurrencySelectionViewController from storyboard")
        
        mockCoinManager = MockCoinManager()
        mockDelegate = MockPriceUpdaterDelegate()
        
        sut.coinManager = mockCoinManager // Inject the mock
        sut.delegate = mockDelegate // Assign the mock delegate
        
        _ = sut.view // Force view to load
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockCoinManager = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    //    func testViewController_ReceivesPriceUpdate_DelegateUpdatesUIAccordingly() {
    //            // Given
    //            let expectedPrice = "12345.67"
    //            let expectedCurrency = "USD"
    //
    //            // When
    //           mockDelegate.didUpdatePrice(price: expectedPrice, currency: expectedCurrency)
    //              //sut.didUpdatePrice(price: expectedPrice, currency: expectedCurrency)
    //
    //            // Then
    //            XCTAssertEqual(sut.bitcoinLabel.text, expectedPrice)
    //            XCTAssertEqual(sut.currencyLabel.text, expectedCurrency)
    //        }
    //    
    //    func testViewController_HandleLogout_UserSessionClearedAndNavigatedToWelcomeScreen() {
    //            // Given
    //            // Simulate a user being logged in
    //            mockSessionManager.isLoggedIn = true
    //            
    //            // When
    //            // Simulate tapping the logout button
    //            sut.logOutPressed(UIBarButtonItem())
    //            
    //            // Then
    //            // Verify the user session is cleared
    //            XCTAssertFalse(mockSessionManager.isLoggedIn, "The user session should be cleared after logging out.")
    //            
    //            // Verify navigation to the welcome screen occurred
    //            XCTAssertTrue(mockNavigator.didNavigateToWelcomeScreen, "The app did not navigate to the welcome screen after logout.")
    //        }
    //
    //
    //}
}
