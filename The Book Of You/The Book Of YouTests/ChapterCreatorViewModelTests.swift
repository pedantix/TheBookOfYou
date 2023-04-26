//
//  ChapterCreatorViewModelTests.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 4/24/23.
//

import XCTest
import Fakery
@testable import The_Book_Of_You

final class ChapterCreatorViewModelTests: BackgroundContextTestCase {
    let faker = Faker()

    func testCreateGoalIsCreatable() throws {
        let ccvm = ChapterCreatorViewModel(context)
        XCTAssertFalse(ccvm.isGoalCreatable)

        ccvm.goalText = " "
        XCTAssertFalse(ccvm.isGoalCreatable)
        let text = faker.car.brand()
        ccvm.goalText = " \(text) "
        XCTAssertTrue(ccvm.isGoalCreatable)

        let aGoal = Goal(context: context)
        aGoal.title = text
        try context.save()
        XCTAssertFalse(ccvm.isGoalCreatable)
    }

    func testCreateGoal() throws {
        let ccvm = ChapterCreatorViewModel(context)
        let aVeryDesiredName = "a Very Desired name"
        let untrimmed = " \(aVeryDesiredName) "
        let req = Goal.goalsThatAre(named: aVeryDesiredName)

        try XCTAssertEqual(0, context.count(for: req))

        ccvm.goalText = untrimmed
        XCTAssertTrue(ccvm.isGoalCreatable)

        ccvm.createGoal()
        try XCTAssertEqual(1, context.count(for: req))
        XCTAssertEqual("", ccvm.goalText)

        let goals = try context.fetch(req)

        XCTAssertEqual(1, ccvm.chapterGoals.count)
        XCTAssertEqual(goals, ccvm.chapterGoals)
    }

    func testCreateGoalThatIsDuplicate() throws {
        let ccvm = ChapterCreatorViewModel(context)
        let aVeryDesiredName = "a Very Desired name"
        let untrimmed = " \(aVeryDesiredName) "
        let req = Goal.goalsThatAre(named: aVeryDesiredName)

        ccvm.goalText = untrimmed
        ccvm.createGoal()
        try XCTAssertEqual(1, context.count(for: req))
        XCTAssertEqual("", ccvm.goalText)

        ccvm.goalText = aVeryDesiredName
        ccvm.createGoal()
        XCTAssertEqual(1, ccvm.chapterGoals.count)
    }

    func testCreateGoalsLimitDoesNotAddGoalsToListInsteadDoesNotClearAndAddsToPool() throws {
        let ccvm = ChapterCreatorViewModel(context)

        XCTAssertEqual(ccvm.chapterGoals, [])
        for goalTitle in ["happy", "sleepy", "sneezy", "doc", "block"] {
            ccvm.goalText = goalTitle
            ccvm.createGoal()
        }
        let goalsCopy = ccvm.chapterGoals
        XCTAssertEqual(ccvm.chapterGoals.count, 5)
        ccvm.goalText = "Bashful"
        ccvm.createGoal()
        XCTAssertEqual(ccvm.chapterGoals.count, 5)
        XCTAssertEqual(goalsCopy, ccvm.chapterGoals)
        let goalsInList = try context.fetch(ccvm.goalFetchRequest)
        XCTAssertEqual(1, goalsInList.count)
        XCTAssertEqual("Bashful", goalsInList.first?.title)
    }

}
