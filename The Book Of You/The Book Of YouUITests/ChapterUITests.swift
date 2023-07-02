//
//  ChapterUITests.swift
//  The Book Of YouUITests
//
//  Created by Shaun Hubbard on 5/31/23.
//

import XCTest

final class ChapterUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testWithExistingGoals() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchUITestWithEnvironmentVariables(["Scenario": "sixGoals"])

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

        // Add the title
        let titleField = app.textFields["Chapter Title - Editable In the Future"]

        XCTAssertTrue(titleField.exists)

        titleField.tap()
        let titleText = "A strong chapter"
        titleField.typeText(titleText)
        app.keyboards.buttons["Done"].tap()

        // Add the goals

        for goalId in 1...5 {
            let goalCell = app.cells.staticTexts["Goal \(goalId)"]
            XCTAssertTrue(goalCell.exists)
            goalCell.tap()
        }

        let saveButton = app.navigationBars.buttons["Save"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()

        // Verify new chapter was created
        let newChapterCell = app.cells.staticTexts[titleText]
        XCTAssertTrue(newChapterCell.exists)
        let createNewPageCell = app.cells.staticTexts["Create a New Page!"]
        XCTAssertTrue(createNewPageCell.exists)
    }

    func testWithExistingGoalsForVacationChapter() throws {
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

        // Add the title
        let titleField = app.textFields["Chapter Title - Editable In the Future"]

        XCTAssertTrue(titleField.exists)

        titleField.tap()
        let titleText = "A strong chapter"
        titleField.typeText(titleText)

        // Toggle Vacation

        let goalCell = app.cells.staticTexts["Goal 1"]
        XCTAssertTrue(goalCell.exists)

        let vacationSwitch = app.switches["Vacation Toggle"]
        let vacationToggle = vacationSwitch.switches.firstMatch
        XCTAssertTrue(vacationSwitch.exists)
        XCTAssertTrue(vacationToggle.exists)
        XCTAssertEqual(vacationSwitch.value as? String, "0")

        vacationToggle.press(forDuration: 0.1)
        XCTAssertFalse(goalCell.exists)

        XCTAssertEqual(vacationSwitch.value as? String, "1")

        let saveButton = app.navigationBars.buttons["Save"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()

        // Verify new chapter was created
        let newChapterCell = app.cells.staticTexts[titleText]
        XCTAssertTrue(newChapterCell.exists)
        let createNewPageCell = app.cells.staticTexts["Create a New Page!"]
        XCTAssertTrue(createNewPageCell.exists)
    }

    func testWithExistingGoalsForCustomAmountOfGoals() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchUITestWithEnvironmentVariables(["Scenario": "sixGoals"])

        // Accessibility button for cover page.
        app.buttons["Click to turn the page"].tap()

        // Adjust goals
        let defaultGoalsStepper = app.steppers["Identity Goals: 5"]
        XCTAssert(defaultGoalsStepper.swipeUpUntilElementFound(app: app))

        for step in 0...2 {
            app.steppers["Identity Goals: \(5 - step)"].buttons["Decrement"].tap()
        }

        // Navigate to index
        let indexButton = app.navigationBars.buttons["Index"]
        XCTAssert(indexButton.exists)
        indexButton.tap()
        XCTAssertTrue(app.staticTexts["Index"].exists)

        let newButton = app.navigationBars.buttons["New"]
        XCTAssert(newButton.exists)
        newButton.tap()

        XCTAssertTrue(app.staticTexts["Chapter creator"].exists)

        // Add the title
        let titleField = app.textFields["Chapter Title - Editable In the Future"]

        XCTAssertTrue(titleField.exists)

        titleField.tap()
        let titleText = "A strong chapter"
        titleField.typeText(titleText)

        // Add the goals

        for goalId in 1...5 {
            let goalCell = app.cells.staticTexts["Goal \(goalId)"]
            XCTAssertTrue(goalCell.exists)
            goalCell.tap()
        }

        let saveButton = app.navigationBars.buttons["Save"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()

        // Verify new chapter was created
        let newChapterCell = app.cells.staticTexts[titleText]
        XCTAssertTrue(newChapterCell.exists)
        let createNewPageCell = app.cells.staticTexts["Create a New Page!"]
        XCTAssertTrue(createNewPageCell.exists)
    }

    func testWithExistingChapterNoPage() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchUITestWithEnvironmentVariables(["Scenario": "chapterCreated"])

        // Accessibility button for cover page.
        app.buttons["Click to turn the page"].tap()

        // Navigate to index
        let indexButton = app.navigationBars.buttons["Index"]
        XCTAssert(indexButton.exists)
        indexButton.tap()
        XCTAssertTrue(app.staticTexts["Index"].exists)

        let preexistingChapter = app.cells.staticTexts["A chapter from 1 days ago"]

        XCTAssertTrue(preexistingChapter.exists)

        let newButton = app.navigationBars.buttons["New"]
        XCTAssert(newButton.exists)
        newButton.tap()

        XCTAssertTrue(app.staticTexts["Chapter creator"].exists)

        // Add the title
        let titleField = app.textFields["Chapter Title - Editable In the Future"]

        XCTAssertTrue(titleField.exists)

        titleField.tap()
        titleField.buttons["Clear text"].tap()
        let titleText = "A strong chapter 2"
        titleField.typeText(titleText)

        let saveButton = app.navigationBars.buttons["Save"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()

        // Verify new chapter was created
        let newChapterCell = app.cells.staticTexts[titleText]
        XCTAssertTrue(newChapterCell.exists)
        let createNewPageCell = app.cells.staticTexts["Create a New Page!"]
        XCTAssertTrue(createNewPageCell.exists)
        XCTAssertFalse(preexistingChapter.exists)
    }

    func testWithExistingChapterWithAPage() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchUITestWithEnvironmentVariables(["Scenario": "chapterCreatedWithAPage"])

        // Accessibility button for cover page.
        app.buttons["Click to turn the page"].tap()

        // Navigate to index
        let indexButton = app.navigationBars.buttons["Index"]
        XCTAssert(indexButton.exists)
        indexButton.tap()
        XCTAssertTrue(app.staticTexts["Index"].exists)

        let preexistingChapter = app.cells.staticTexts["A chapter from 5 days ago"]

        XCTAssertTrue(preexistingChapter.exists)

        let newButton = app.navigationBars.buttons["New"]
        XCTAssert(newButton.exists)
        newButton.tap()

        XCTAssertTrue(app.staticTexts["Chapter creator"].exists)

        // Add the title
        let titleField = app.textFields["Chapter Title - Editable In the Future"]

        XCTAssertTrue(titleField.exists)

        titleField.tap()
        titleField.buttons["Clear text"].tap()
        let titleText = "A strong chapter 2"
        titleField.typeText(titleText)

        let saveButton = app.navigationBars.buttons["Save"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()

        // Verify new chapter was created
        let newChapterCell = app.cells.staticTexts[titleText]
        XCTAssertTrue(newChapterCell.exists)
        let createNewPageCell = app.cells.staticTexts["Create a New Page!"]
        XCTAssertTrue(createNewPageCell.exists)
        XCTAssertTrue(preexistingChapter.exists)
    }
}
