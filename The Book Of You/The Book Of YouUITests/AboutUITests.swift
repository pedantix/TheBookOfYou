//
//  AboutUITests.swift
//  The Book Of YouUITests
//
//  Created by Shaun Hubbard on 4/30/23.
//

import XCTest

final class AboutUITests: XCTestCase {
    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface
        // orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    // This page relies on serialization of bundle data a smoke test is sufficent to prove it works
    func testExistence() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchEnvironment = ["Scenario": "blankSlate"]
        app.launch()

        app.windows
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .tap()
        let aboutButton = app.navigationBars["_TtGC7SwiftUI32NavigationStackHosting"].buttons["About"]
        XCTAssert(aboutButton.exists)
        aboutButton.tap()
        XCTAssertTrue(app.staticTexts["About"].exists)
    }
}
