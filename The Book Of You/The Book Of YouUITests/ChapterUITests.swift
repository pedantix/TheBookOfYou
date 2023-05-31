//
//  ChapterUITests.swift
//  The Book Of YouUITests
//
//  Created by Shaun Hubbard on 5/31/23.
//

import XCTest

final class ChapterUITests: XCTestCase {
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testWithExistingGoals() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchEnvironment = ["Scenario": "sixGoals"]
        app.launch()

        // Accessibility button for cover page.
        app.buttons["Click to turn the page"].tap()
        let indexButton = app.navigationBars.buttons["Index"]
        XCTAssert(indexButton.exists)
        indexButton.tap()
        XCTAssertTrue(app.staticTexts["Index"].exists)

        let newButton = app.navigationBars.buttons["New"]
        XCTAssert(newButton.exists)
        newButton.tap()

        XCTAssertTrue(app.staticTexts["Chapter creator"].exists)
    }



    // TODO: Test with existing goals, for vacation chapter

    // TODO: Test with existing chapter, for a recreated chapter

    // TODO: Test adjusting goal number down to two to create a chapter

}
