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
        sut.coinManager?.delegate = mockDelegate
        
        sut.loadViewIfNeeded()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockCoinManager = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    func testViewDidLoad_SetsCoinManagerDelegate() {
        // Arrange: (Already done in setUp)
        
        // Act: (Loading the view is considered an act here)
        
        // Assert
        XCTAssertNotNil(mockCoinManager.delegate, "CoinManager delegate should be set.")
    }
    
    func testPickerView_DidSelectRow_UpdatesCoinPrice() {
            // Arrange:
            let expectedCurrency = mockCoinManager.currencyArray[0]
            
            // Act
            sut.pickerView(sut.currencyPicker, didSelectRow: 0, inComponent: 0)
            
            // Assert
            XCTAssertEqual(sut.selectedCurrency, expectedCurrency, "Selected currency should be updated to AUD.")
        }
    // Test disabled as it requires more refined mocking of asynchronous behavior.
    func testViewController_ReceivesPriceUpdate_DelegateUpdatesUI() {
            // Arrange
            let expectedPrice = "12345.67"
            let expectedCurrency = "USD"

            // Act
           //mockDelegate.didUpdatePrice(price: expectedPrice, currency: expectedCurrency)
              sut.didUpdatePrice(price: expectedPrice, currency: expectedCurrency)

            // Assert
            XCTAssertEqual(sut.bitcoinLabel.text, expectedPrice)
            XCTAssertEqual(sut.currencyLabel.text, expectedCurrency)
        }
    
}
