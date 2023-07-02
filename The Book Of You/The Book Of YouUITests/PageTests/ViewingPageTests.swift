//
//  ViewingPageTests.swift
//  The Book Of YouUITests
//
//  Created by Shaun Hubbard on 6/30/23.
//

import XCTest

final class ViewingPageTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testViewingAPageFromAChapterWithFiveGoals() {
        let app = XCUIApplication()
        app.launchUITestWithEnvironmentVariables(["Scenario": "chapterCreatedWithAPage"])

        app.navigateToIndex()

        let pageToView = app.cells.staticTexts["1"]
        XCTAssert(pageToView.exists)
        pageToView.tap()

        let dateView = app.datePickers["Entry Date"]
        XCTAssertTrue(dateView.exists)

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        let dateStr = dateFormatter.string(from: .now)
        XCTAssertEqual(dateView.buttons.firstMatch.value as? String, dateStr)

        let vacationToggle = app.switches["Vacation Day"]
        XCTAssertEqual(vacationToggle.value as? String, "0")

        XCTAssert(app.staticTexts["Goal 1"].swipeUpUntilElementFound(app: app))
        XCTAssert(app.staticTexts["Page Text 1"].exists)

        XCTAssert(app.staticTexts["Goal 2"].swipeUpUntilElementFound(app: app))
        XCTAssert(app.staticTexts["Page Text 2"].exists)

        XCTAssert(app.staticTexts["Goal 3"].swipeUpUntilElementFound(app: app))
        XCTAssert(app.staticTexts["Page Text 3"].exists)

        XCTAssert(app.staticTexts["Goal 4"].swipeUpUntilElementFound(app: app))
        XCTAssert(app.staticTexts["Page Text 4"].exists)

        XCTAssert(app.staticTexts["Goal 5"].swipeUpUntilElementFound(app: app))
        XCTAssert(app.staticTexts["Page Text 5"].exists)
    }

    func testViewingAPageFromAChapterWithTwoGoals() {
        let app = XCUIApplication()
        app.launchUITestWithEnvironmentVariables(["Scenario": "twoGoalChapterCreatedWithAPage"])

        app.navigateToIndex()

        let pageToView = app.cells.staticTexts["1"]
        XCTAssert(pageToView.exists)
        pageToView.tap()

        let dateView = app.datePickers["Entry Date"]
        XCTAssertTrue(dateView.exists)

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        let dateStr = dateFormatter.string(from: .now)
        XCTAssertEqual(dateView.buttons.firstMatch.value as? String, dateStr)

        let vacationToggle = app.switches["Vacation Day"]
        XCTAssertEqual(vacationToggle.value as? String, "0")

        XCTAssert(app.staticTexts["Goal 1"].swipeUpUntilElementFound(app: app))
        XCTAssert(app.staticTexts["Page Text 1"].exists)

        XCTAssert(app.staticTexts["Goal 2"].swipeUpUntilElementFound(app: app))
        XCTAssert(app.staticTexts["Page Text 2"].exists)

        XCTAssertFalse(app.staticTexts["Goal 3"].exists)
    }

    func testViewingAPageFromAVacationChapter() {
        let app = XCUIApplication()
        app.launchUITestWithEnvironmentVariables(["Scenario": "chapterCreatedWithAVacationPage"])

        app.navigateToIndex()

        let pageToView = app.cells.staticTexts["1"]
        XCTAssert(pageToView.exists)
        pageToView.tap()

        let dateView = app.datePickers["Entry Date"]
        XCTAssertTrue(dateView.exists)

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        let dateStr = dateFormatter.string(from: .now)
        XCTAssertEqual(dateView.buttons.firstMatch.value as? String, dateStr)

        let vacationToggle = app.switches["Vacation Day"]
        XCTAssertEqual(vacationToggle.value as? String, "0")

        XCTAssert(app.staticTexts["Vacation Day Journal Entry"].exists)
    }

    func testViewingAVacationDayPage() {
        let app = XCUIApplication()
        app.launchUITestWithEnvironmentVariables(["Scenario": "vacationChapterCreatedWithAPage"])

        app.navigateToIndex()

        let pageToView = app.cells.staticTexts["1"]
        XCTAssert(pageToView.exists)
        pageToView.tap()

        let dateView = app.datePickers["Entry Date"]
        XCTAssertTrue(dateView.exists)

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        let dateStr = dateFormatter.string(from: .now)
        XCTAssertEqual(dateView.buttons.firstMatch.value as? String, dateStr)
        XCTAssert(app.staticTexts["Vacation Chapter Journal Entry"].exists)
    }
}
