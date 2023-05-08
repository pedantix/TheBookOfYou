//
//  GoalViewModelTests.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 4/24/23.
//

import XCTest
@testable import The_Book_Of_You

final class GoalViewModelTests: BackgroundContextTestCase {
    private var goal: Goal!
    private var gvm: GoalViewModel!

    override func setUp() async throws {
        try await super.setUp()
        goal = context.addGoal("a goal")
        gvm = GoalViewModel(goal: goal, alertMessenger: DummyAlertMessenger(), context: context)
    }

    func testTitle() throws {
        goal.title = nil
        XCTAssertEqual("BAD GOAL, NO TITLE", gvm.title)
        let goalTitle = "Be a Runner"
        goal.title = goalTitle
        XCTAssertEqual(goalTitle, gvm.title)
    }

    func testDeletable() throws {
        XCTAssertTrue(gvm.isDeletable)
        let chapter = Chapter(context: context)
        try context.save()

        let chapGoal = ChapterGoal(context: context)
        chapGoal.chapter = chapter
        chapGoal.goal = goal
        try context.save()

        XCTAssertFalse(gvm.isDeletable)
    }

    func testIsEditing() throws {
        let initialTitle = goal.title
        XCTAssertEqual(gvm.editableTitle, "", "Initial value")
        gvm.isEditing = true
        XCTAssertEqual(gvm.editableTitle, initialTitle, "Title changed to value of goal")
        gvm.editableTitle = "Something entirely different"
        XCTAssertEqual(gvm.editableTitle, "Something entirely different", "Title changes to user input")
        XCTAssertEqual(goal.title, initialTitle, "Goal only changes on save!")
        gvm.isEditing = false
        XCTAssertEqual(goal.title, initialTitle, "Goal only changes on save!")
        XCTAssertEqual(gvm.editableTitle, initialTitle, "Test is editing resets title")
    }

    func testSaveEditing() throws {
        gvm.isEditing = true
        let updatedTitle = "an updated title"
        gvm.editableTitle = " \t \n"
        XCTAssertFalse(gvm.isSavable)
        gvm.editableTitle = ""
        XCTAssertFalse(gvm.isSavable)
        gvm.editableTitle = " "
        XCTAssertFalse(gvm.isSavable)
        gvm.editableTitle = updatedTitle
        XCTAssertTrue(gvm.isSavable)
        XCTAssertNotEqual(goal.title, updatedTitle)
        gvm.saveEdit()
        XCTAssertEqual(goal.title, updatedTitle)
        XCTAssertFalse(goal.isUpdated)
        XCTAssertFalse(gvm.isEditing)
    }

    func testSaveEditingTrims() throws {
        gvm.isEditing = true
        let updatedTitle = "an updated title"
        gvm.editableTitle = updatedTitle + " "
        XCTAssertTrue(gvm.isSavable)
        XCTAssertNotEqual(goal.title, updatedTitle)
        gvm.saveEdit()
        XCTAssertEqual(goal.title, updatedTitle)
        XCTAssertFalse(goal.isUpdated)
        XCTAssertFalse(gvm.isEditing)
    }

    func testDeleteForDeletable() throws {
        XCTAssertTrue(gvm.isDeletable)
        XCTAssertEqual(1, try context.count(for: Goal.fetchRequest()))
        gvm.delete()
        XCTAssertEqual(0, try context.count(for: Goal.fetchRequest()))
    }

    func testDeleteForNonDeletable() throws {
        let goalWithChap = context.addGoal(with: context.addChapter())
        gvm = GoalViewModel(goal: goalWithChap, alertMessenger: DummyAlertMessenger(), context: context)
        XCTAssertFalse(gvm.isDeletable)
        gvm.delete()
        XCTAssertEqual(2, try context.count(for: Goal.fetchRequest()))
    }

    func testCancelEdit() {
        gvm.isEditing = true
        XCTAssertTrue(gvm.isEditing)
        gvm.cancelEdit()
        XCTAssertFalse(gvm.isEditing)
    }
}
