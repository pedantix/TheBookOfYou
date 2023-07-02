//
//  XCUIApplication.swift
//  The Book Of YouUITests
//
//  Created by Shaun Hubbard on 6/29/23.
//

import XCTest

extension XCUIApplication {
    func launchUITestWithEnvironmentVariables(_ variables: [String: String] = [:]) {
        var defaultVariables = ["UI_TEST": "1"]
        defaultVariables.merge(variables, uniquingKeysWith: { (curent, _) in curent })
        launchEnvironment = defaultVariables
        launch()
    }
}

extension XCUIApplication {
    func navigateToIndex() {
        // Accessibility button for cover page.
        self.buttons["Click to turn the page"].tap()
        let indexButton = self.navigationBars.buttons["Index"]
        XCTAssert(indexButton.exists)
        indexButton.tap()
        XCTAssertTrue(self.staticTexts["Index"].exists)
    }
}
