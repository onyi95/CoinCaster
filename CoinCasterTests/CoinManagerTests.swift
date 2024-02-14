//
//  CoinManagerTests.swift
//  CoinCasterTests
//
//  Created by Onyi Esu on 11/02/2024.
//

import XCTest
@testable import CoinCaster

final class CoinManagerTests: XCTestCase {
    var sut: CoinManager!
    var mockSession: MockURLSession!
    var mockDelegate: MockPriceUpdaterDelegate!

    override func setUp() {
        super.setUp()
        let sampleData = "{\"key\":\"value\"}".data(using: .utf8) // Example JSON response
        let sampleURLResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let sampleError: Error? = nil // No error
        
        mockSession = MockURLSession(data: sampleData, urlResponse: sampleURLResponse, error: sampleError)
        mockDelegate = MockPriceUpdaterDelegate()
        sut = CoinManager(session: mockSession)
        sut.delegate = mockDelegate
    }

    override func tearDown() {
        sut = nil
        mockSession = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    func test_UpdateCoinPrice_CallsCorrectURL() {
            // Arrange
            let currency = "USD"
            let baseURL = API.baseURL
            let apiKey = API.apiKey

            
            // Act
            sut.updateCoinPrice(currency)
            
            //Assert
            XCTAssertEqual(mockSession.lastURL, URL(string: "\(baseURL)/\(currency)/?apikey=\(apiKey)"))
        }
    
    func test_UpdateCoinPrice_SuccessfullyParsesData() {
        // Arrange
        let currency = "USD"
        let expectedPrice = 1234.56
        let mockData = "{\"rate\":\(expectedPrice)}".data(using: .utf8)!
        let mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        mockSession = MockURLSession(data: mockData, urlResponse: mockResponse, error: nil)
        sut = CoinManager(session: mockSession)

        // Act
        sut.updateCoinPrice(currency)

        // Assert
        mockDelegate.updatePriceCompletion = { price, currency in
            XCTAssertEqual(price, "1234.56")
            XCTAssertEqual(currency, "USD")
        }
    }

    func test_UpdateCoinPrice_FailsWithError() {
        // Arrange
        let currency = "USD"
        let mockError = NSError(domain: "com.CoinCaster.network", code: -1009, userInfo: nil)
        mockSession = MockURLSession(data: nil, urlResponse: nil, error: mockError)
        sut = CoinManager(session: mockSession)
        
        let mockDelegate = MockPriceUpdaterDelegate()
        sut.delegate = mockDelegate
        
        // Act
        sut.updateCoinPrice(currency)
        
        // Assert
        mockDelegate.failureCompletion = { error in
            XCTAssertNotNil(error, "There should be an error")
        }
    }
    
    func test_RegisterUser_Success() {
        // Arrange
        let expectation = self.expectation(description: "RegisterUserSucceeds")
        let email = "test@example.com"
        let password = "password123"
        let mockResponseJSON = """
        {
            "user_id": 12345,
            "message": "Registration successful"
        }
        """.data(using: .utf8)!  // The real function is expecting some data back for a successful registration
        let mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 201, httpVersion: nil, headerFields: nil)!
        mockSession = MockURLSession(data: mockResponseJSON, urlResponse: mockResponse, error: nil)
        sut = CoinManager(session: mockSession)


        // Act
        sut.registerUser(email: email, password: password) { result in
            if case .success(let statusCode) = result {
        
                // Assert
                XCTAssertEqual(statusCode, 201)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func test_RegisterUser_EmailAlreadyInUse() {
        // Arrange
        let expectation = self.expectation(description: "RegisterUserFails")
        let email = "test@example.com"
        let password = "password123"
        let mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 409, httpVersion: nil, headerFields: nil)!
        mockSession = MockURLSession(data: nil, urlResponse: mockResponse, error: nil)
        sut = CoinManager(session: mockSession)

        // Act
        sut.registerUser(email: email, password: password) { result in
            if case .failure(let error) = result, case .emailAlreadyInUse = error {
                
                // Assert
                XCTAssertNotNil(error, "There should be an error when email is already in use")
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func test_RegisterUser_OtherError() {
        // Arrange
        let expectation = self.expectation(description: "RegisterUserFails")
        let email = "test@example.com"
        let password = "password123"
        let mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 300, httpVersion: nil, headerFields: nil)!
        mockSession = MockURLSession(data: nil, urlResponse: mockResponse, error: nil)
        sut = CoinManager(session: mockSession)

        // Act
        sut.registerUser(email: email, password: password) { result in
            if case .failure(let error) = result, case .other(300) = error {
                
                // Assert
                XCTAssertNotNil(error, "There should be an error when status code is anything other than 201")
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func test_LoginUser_Success() {
        // Arrange
        let expectation = self.expectation(description: "LoginUserSucceeds")
        let email = "user@example.com"
        let password = "password"
        let mockResponseJSON = """
        {
            "user_id": 12345,
            "message": "Login successful"
        }
        """.data(using: .utf8)!  // The real function is expecting some data back for a successful login
        let mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        mockSession = MockURLSession(data: mockResponseJSON, urlResponse: mockResponse, error: nil)
        sut = CoinManager(session: mockSession)


        // Act
        sut.loginUser(email: email, password: password) { result in
            if case .success(let statusCode) = result {
        
                // Assert
                XCTAssertEqual(statusCode, 200)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func test_LoginUser_InvalidCredentials() {
        // Arrange
        let expectation = self.expectation(description: "LoginUserFails")
        let email = "wrong@example.com"
        let password = "wrongPassword"
        let mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 401, httpVersion: nil, headerFields: nil)!
        mockSession = MockURLSession(data: nil, urlResponse: mockResponse, error: nil)
        sut = CoinManager(session: mockSession)


        // Act
        sut.loginUser(email: email, password: password) { result in
            if case .failure(let error) = result, case .invalidCredentials = error {
        
                // Assert
                XCTAssertNotNil(error, "There should be an error when incorrect credentials are entered")
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func test_LoginUser_OtherError() {
        // Arrange
        let expectation = self.expectation(description: "LoginUserFails")
        let email = "test@example.com"
        let password = "password123"
        let mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 300, httpVersion: nil, headerFields: nil)!
        mockSession = MockURLSession(data: nil, urlResponse: mockResponse, error: nil)
        sut = CoinManager(session: mockSession)

        // Act
        sut.loginUser(email: email, password: password) { result in
            if case .failure(let error) = result, case .other(300) = error {
                
                // Assert
                XCTAssertNotNil(error, "There should be an error when status code is anything other than 200")
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func test_SendDeviceTokenToServer_Success_TokenSentToServer() {
        // Arrange
        let expectation = self.expectation(description: "TokenSentSuccessfully")
        let token = "aFbiYjS8"
        let userId = "5"
        let data = Data()
        let mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        mockSession = MockURLSession(data: data, urlResponse: mockResponse, error: nil)
        sut = CoinManager(session: mockSession)
        
        // Act
        sut.sendDeviceTokenToServer(token: token, userId: userId) {success in
        
            // Assert
            XCTAssertTrue(success, "Token should be sent to the server")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func test_SendDeviceTokenToServer_Failure_TokenNotSentToServer() {
        // Arrange
        let expectation = self.expectation(description: "TokenNotSent")
        let error = NSError(domain: "test", code: 0, userInfo: nil)
        let mockSession = MockURLSession(data: nil, urlResponse: nil, error: error)
        let sut = CoinManager(session: mockSession)

        // Act
        sut.sendDeviceTokenToServer(token: "dummyToken", userId: "dummyUserId") {
            success in
        
            // Assert
            XCTAssertFalse(success, "Token should not be sent to the server" )
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testLogoutUser_Successful() {
        // Arrange
        let expectation = self.expectation(description: "UserLogoutSuccess")
        let userId = "123"
        let mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let mockSession = MockURLSession(data: nil, urlResponse: mockResponse, error: nil)
        let sut = CoinManager(session: mockSession)
        

        // Act
        sut.logoutUser(withUserId: userId) { success in
            
            // Assert
            XCTAssertTrue(success, "User should be logged out successfuly when status code 200 is returned")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testLogoutUser_NetworkError() {
        // Arrange
        let expectation = self.expectation(description: "UserLogoutFailure")
        let error = NSError(domain: "com.test.error", code: -1, userInfo: nil)
        let mockSession = MockURLSession(data: nil, urlResponse: nil, error: error)
        let sut = CoinManager(session: mockSession)

        // Act
        sut.logoutUser(withUserId: "123") { success in
        
            // Assert
            XCTAssertFalse(success, "User logout should be unsuccessful")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testUserSelectedCurrency_Success() {
        // Arrange
        let expectation = self.expectation(description: "UserSelectedCurrencySent")
        let data = Data()
        userIdNo = 123 // Set a mock user ID
        let mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        mockSession = MockURLSession(data: data, urlResponse: mockResponse, error: nil)
        sut = CoinManager(session: mockSession)
        
        
        // Act
        sut.userSelectedCurrency(currency: "USD") { success in
            
            // Assert
            XCTAssertTrue(success, "Expected userSelectedCurrency to succeed")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
        
     func testUserSelectedCurrency_NetworkError() {
            // Arrange
            let expectation = self.expectation(description: "UserSelectedCurrencyNotSent")
            let error = NSError(domain: "com.test.error", code: -1, userInfo: nil)
            mockSession = MockURLSession(data: nil, urlResponse: nil, error: error)
            sut = CoinManager(session: mockSession)
           
            
            // Act
            sut.userSelectedCurrency(currency: "USD") { success in
                
                // Assert
                XCTAssertFalse(success, "Expected userSelectedCurrency not to succeed")
                expectation.fulfill()
            }
            waitForExpectations(timeout: 5, handler: nil)
        }
    
    func testUserSelectedCurrency_InvalidResponseCode() {
        // Arrange
        let expectation = self.expectation(description: "UserSelectedCurrencyNotSent")
        let mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)!
            mockSession = MockURLSession(data: nil, urlResponse: mockResponse, error: nil)
            sut = CoinManager(session: mockSession)

        // Act
        sut.userSelectedCurrency(currency: "USD") { success in
        
            // Assert
            XCTAssertFalse(success, "Expected userSelectedCurrency not to succeed")
            expectation.fulfill()
    }
        waitForExpectations(timeout: 5, handler: nil)
}
    func testSendTargetPriceToServer_Success() {
        // Arrange
        let expectation = self.expectation(description: "TargetPriceUpdate")
        let data = Data()
        let mockResponse = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        mockSession = MockURLSession(data: data, urlResponse: mockResponse, error: nil)
        sut = CoinManager(session: mockSession)
        userIdNo = 123

        let targetPrice = 10000.0
        currentPrice = 9000.0 // Setting a different current price to pass the if check

        // Act
        sut.sendTargetPriceToServer(targetPrice: targetPrice) { success in
            // Assert
            XCTAssertTrue(success, "Expected sendTargetPriceToServer to succeed")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
        }
    
    func testSendTargetPriceToServer_Failure() {
        // Arrange
        let expectation = self.expectation(description: "TargetPriceDidNotUpdate")
        let error = NSError(domain: "com.test.error", code: -1, userInfo: nil)
        mockSession = MockURLSession(data: nil, urlResponse: nil, error: error)
        sut = CoinManager(session: mockSession)
        userIdNo = 123
        
        let targetPrice = 10000.0
        currentPrice = 9000.0
        
        // Act
        sut.sendTargetPriceToServer(targetPrice: targetPrice) { success in
            
            //Assert
            XCTAssertFalse(success, "Expected sendTargetPriceToServer not to succeed")
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
 



    
    


//    NOTES:
//    Expectations in network testing allow for asynchronous code execution to complete, ensuring tests only evaluate results after network requests and responses have been fully processed.
//    They help prevent false negatives or positives in tests by synchronizing the test's execution flow, waiting for callbacks or completion handlers to be called.
//    Utilizing expectations ensures the reliability and accuracy of tests involving network operations, making them essential for validating the behavior of API calls and response handling.









}
