//
//  CreatingPagesTests.swift
//  The Book Of YouUITests
//
//  Created by Shaun Hubbard on 7/2/23.
//

import XCTest

final class CreatingPagesTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    private func enterAndVerifyTextForGoal(_ app: XCUIApplication, goalEditButton: String, text: String) {
        let textEntrySelector = app.textViews["Enter some text"]
        let updateBtnSelector = app.buttons["Update"]
        let editGoalBtn = app.buttons[goalEditButton]
        XCTAssertTrue(editGoalBtn.swipeUpUntilElementFound(app: app))
        XCTAssertTrue(editGoalBtn.exists)
        editGoalBtn.tap()
        XCTAssert(textEntrySelector.exists)
        textEntrySelector.tap()
        textEntrySelector.typeText(text)

        XCTAssert(updateBtnSelector.exists)
        updateBtnSelector.tap()
        XCTAssert(app.staticTexts[text].exists)

    }

    func testCreatingAPageForAChapterWithFiveGoals() {
        let app = XCUIApplication()
        app.launchUITestWithEnvironmentVariables(["Scenario": "chapterCreated"])
        app.navigateToIndex()

        let pageCreator = app.staticTexts["Create a New Page!"]
        XCTAssert(pageCreator.exists)
        pageCreator.tap()

        // Goal 1 verify
        let editGoal1Btn = app.buttons["Edit Goal 1"]
        XCTAssertTrue(editGoal1Btn.exists)
        editGoal1Btn.tap()
        sleep(1)
        editGoal1Btn.tap()
        let textEntrySelector = app.textViews["Enter some text"]
        XCTAssert(textEntrySelector.exists)
        let textGoal1 = "Goal 1 text entry"
        textEntrySelector.tap()
        textEntrySelector.typeText(textGoal1)

        let updateBtnSelector = app.buttons["Update"]
        XCTAssert(updateBtnSelector.exists)
        updateBtnSelector.tap()
        XCTAssert(app.staticTexts[textGoal1].exists)

        // Goal 2 verify
        enterAndVerifyTextForGoal(app, goalEditButton: "Edit Goal 2", text: "Goal 2 text entry")
        enterAndVerifyTextForGoal(app, goalEditButton: "Edit Goal 3", text: "Goal 3 text entry")
        enterAndVerifyTextForGoal(app, goalEditButton: "Edit Goal 4", text: "Goal 4 text entry")
        enterAndVerifyTextForGoal(app, goalEditButton: "Edit Goal 5", text: "Goal 5 text entry")
        let saveBtn = app.buttons["Publish"]
        XCTAssert(saveBtn.exists)
        saveBtn.tap()

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        let dateStr = dateFormatter.string(from: .now)
        XCTAssert(app.cells.staticTexts[dateStr].exists)
    }

    func testCreatingAVacationPageForAChapterWithFiveGoals() {
        let app = XCUIApplication()
        app.launchUITestWithEnvironmentVariables(["Scenario": "chapterCreated"])
        app.navigateToIndex()

        let pageCreator = app.staticTexts["Create a New Page!"]
        XCTAssert(pageCreator.exists)
        pageCreator.tap()

        let editBtn = app.buttons["Edit Goal 1"]
        XCTAssertTrue(editBtn.exists)
        editBtn.tap()
        sleep(1)

        let vacationToggle = app.switches["Vacation Day"]
        XCTAssert(vacationToggle.exists)

        vacationToggle.switches.firstMatch.tap()

        enterAndVerifyTextForGoal(app, goalEditButton: "Edit Journal Entry", text: "A Vacation Entry")

        let saveBtn = app.buttons["Publish"]
        XCTAssert(saveBtn.exists)
        saveBtn.tap()

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        let dateStr = dateFormatter.string(from: .now)
        XCTAssert(app.cells.staticTexts[dateStr].exists)

    }

    func testCreatingAPageForAVacationChapter() {
        let app = XCUIApplication()
        app.launchUITestWithEnvironmentVariables(["Scenario": "vacationChapterCreated"])
        app.navigateToIndex()

        let pageCreator = app.staticTexts["Create a New Page!"]
        XCTAssert(pageCreator.exists)
        pageCreator.tap()

        let vacationToggle = app.switches["Vacation Day"]
        XCTAssertFalse(vacationToggle.exists)

        let editBtn = app.buttons["Edit Journal Entry"]
        XCTAssertTrue(editBtn.exists)
        editBtn.tap()
        sleep(1)
        enterAndVerifyTextForGoal(app, goalEditButton: "Edit Journal Entry", text: "A Vacation Entry")

        let saveBtn = app.buttons["Publish"]
        XCTAssert(saveBtn.exists)
        saveBtn.tap()

        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        let dateStr = dateFormatter.string(from: .now)
        XCTAssert(app.cells.staticTexts[dateStr].exists)
    }
}
