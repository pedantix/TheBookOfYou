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
    private let goalTexts = ["happy", "sleepy", "sneezy", "doc", "slops"]
    private let faker = Faker()
    private var ccvm: ChapterCreatorViewModel!

    override func setUp() async throws {
        try await super.setUp()
        ccvm = await ChapterCreatorViewModel(context)
    }

    // MARK: - GOALS
    func testCreateGoalIsCreatable() throws {
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
        XCTAssertEqual(ccvm.chapterGoals, [])
        XCTAssertNil(ccvm.actionAlert)
        for goalTitle in goalTexts {
            ccvm.goalText = goalTitle
            ccvm.createGoal()
        }
        XCTAssertNil(ccvm.actionAlert)
        let goalsCopy = ccvm.chapterGoals
        XCTAssertEqual(ccvm.chapterGoals.count, 5)
        ccvm.goalText = "Bashful"
        ccvm.createGoal()
        XCTAssertEqual(ccvm.chapterGoals.count, 5)
        XCTAssertEqual(goalsCopy, ccvm.chapterGoals)
        let goalsInList = try context.fetch(ccvm.goalFetchRequest)
        XCTAssertEqual(1, goalsInList.count)
        XCTAssertNotNil(ccvm.actionAlert)
        XCTAssertEqual("Bashful", goalsInList.first?.title)
    }

    func testMaxGoalsReached() throws {
        XCTAssertFalse(ccvm.maxGoalsReached)
        XCTAssertNil(ccvm.actionAlert)
        for goalTitle in goalTexts[...3] {
            ccvm.goalText = goalTitle
            ccvm.createGoal()
        }
        XCTAssertFalse(ccvm.maxGoalsReached)
        ccvm.goalText = "Blintzy"
        ccvm.createGoal()
        XCTAssertTrue(ccvm.maxGoalsReached)
    }

    func testGoalsToGo() throws {
        XCTAssertEqual(5, ccvm.goalsToGo)
        for (idx, goalTitle) in goalTexts[...3].enumerated() {
            ccvm.goalText = goalTitle
            ccvm.createGoal()
            XCTAssertEqual(4 - idx, ccvm.goalsToGo)
        }
        ccvm.goalText = "Blintzy"
        ccvm.createGoal()
        XCTAssertEqual(0, ccvm.goalsToGo)
    }

    func testAddToChapterGoals() throws {
        XCTAssertEqual(5, ccvm.goalsToGo)
        for (idx, goalTitle) in goalTexts.enumerated() {
            let newGoal = context.addGoal(goalTitle)
            XCTAssertTrue(ccvm.addToChapterGoals(newGoal))
            XCTAssertEqual(4 - idx, ccvm.goalsToGo)
        }
        let lastGoal = context.addGoal("docs")
        XCTAssertNil(ccvm.actionAlert)
        XCTAssertFalse(ccvm.addToChapterGoals(lastGoal))
        XCTAssertNotNil(ccvm.actionAlert)
        XCTAssertEqual(0, ccvm.goalsToGo)
    }

    func testRemoveChapterGoals() throws {
        let goals = goalTexts.map {
            context.addGoal($0)
        }

        for (idx, goal) in goals.enumerated() {
            XCTAssertTrue(ccvm.addToChapterGoals(goal))
            XCTAssertEqual(4 - idx, ccvm.goalsToGo)
        }

        for (idx, goal) in goals.enumerated() {
            XCTAssertEqual(idx, ccvm.goalsToGo)
            ccvm.removeChapterGoal(goal)
        }
        XCTAssertEqual(5, ccvm.goalsToGo)
    }

    // MARK: - Chapter Itself
    func testIsCreatable() {
        XCTAssertFalse(ccvm.isChapterCreatable)
        for goalText in goalTexts {
            ccvm.goalText = goalText
            ccvm.createGoal()
        }
        XCTAssertFalse(ccvm.isChapterCreatable)
        ccvm.title = "  \n \t "
        XCTAssertFalse(ccvm.isChapterCreatable)
        ccvm.title = " some text "
        XCTAssertTrue(ccvm.isChapterCreatable)
    }

    func testIsCreatableTitleFirst() {
        XCTAssertFalse(ccvm.isChapterCreatable)
        ccvm.title = "  \n \t "
        XCTAssertFalse(ccvm.isChapterCreatable)
        ccvm.title = " some text "
        XCTAssertFalse(ccvm.isChapterCreatable)
        for goalText in goalTexts {
            ccvm.goalText = goalText
            ccvm.createGoal()
        }
        XCTAssertTrue(ccvm.isChapterCreatable)
    }

    func testCreateNewChapter() throws {
        let chapterText = "Expected Text's"
        ccvm.title = " \(chapterText) "
        for goalText in goalTexts {
            ccvm.goalText = goalText
            ccvm.createGoal()
        }
        XCTAssertTrue(ccvm.isChapterCreatable)
        ccvm.createChapter()

        guard let chapterFromPersistence = try context.fetch(Chapter.fetchRequest()).first
        else { return XCTFail("chapter should have been saved") }

        XCTAssertEqual(chapterFromPersistence.title, chapterText)
        let sortedChapGoals = chapterFromPersistence.chapterGoals?
            .compactMap { $0 as? ChapterGoal }
            .sorted { goalA, goalB in goalA.orderIdx < goalB.orderIdx } ?? []

        for (idx, goalText) in goalTexts.enumerated() {
            let chapGoal = sortedChapGoals[idx]

            XCTAssertEqual(Int(chapGoal.orderIdx), idx)
            XCTAssertEqual(chapGoal.goal?.title, goalText)
        }

        // TODO: TEST navigates too index
    }

    func testCreatingAChapterFromOldChapterWithoutPages() throws {
          // TODO: SHOW that a new chapter populates its data from an old chapter, with no pages and on save purges the old chapter
    }

    func testCreatingAChapterFromOldChapterWithPages() throws {
        // TODO: logic of chapter creation
    }
}
