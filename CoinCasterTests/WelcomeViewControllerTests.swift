//
//  WelcomeViewControllerTests.swift
//  CoinCasterTests
//
//  Created by Onyi Esu on 11/02/2024.
//

import XCTest
@testable import CoinCaster

final class WelcomeViewControllerTests: XCTestCase {
    var sut: WelcomeViewController!

    override func setUpWithError() throws {
        try super.setUpWithError()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(identifier: "WelcomeViewController") as? WelcomeViewController
        sut.loadViewIfNeeded()

    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func test_ProgressView_InitialValue_ShouldBeSetCorrectly() {
            // Arrange is done in setUpWithError()
            
            // Act - Initial value set in viewDidLoad()
            
            // Assert
            XCTAssertEqual(sut.progressView.progress, 0.15, "Initial progress should be set to 0.15")
        }
    
    func test_UpdateProgress_WhenInvoked_ShouldIncrementProgressCorrectly() {
            // Arrange
            let expectedProgress: Float = 0.15 + 0.05 // Incremented by 0.05 from the initial 0.15
            
            // Act
            sut.updateProgress()
            
            // Assert
            XCTAssertEqual(sut.progressView.progress, expectedProgress, "Progress should increment correctly upon update")
        }
    
    func testInvalidateTimer_ShouldStopAndClearTimer() {
         // Arrange
        let sut = WelcomeViewController()
        sut.progressTimer = Timer.scheduledTimer(timeInterval: 1.0, target: sut, selector: #selector(sut.updateProgress), userInfo: nil, repeats: true)
         
         // Act
         sut.invalidateTimer() 
         
         // Assert
         XCTAssertNil(sut.progressTimer, "Timer should be invalidated after reaching full progress")
     }

}
