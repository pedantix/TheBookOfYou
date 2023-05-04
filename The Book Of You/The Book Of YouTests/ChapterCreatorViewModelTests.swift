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
            XCTAssertTrue(ccvm.add(goal: newGoal))
            XCTAssertEqual(4 - idx, ccvm.goalsToGo)
        }
        let lastGoal = context.addGoal("docs")
        XCTAssertNil(ccvm.actionAlert)
        XCTAssertFalse(ccvm.add(goal: lastGoal))
        XCTAssertNotNil(ccvm.actionAlert)
        XCTAssertEqual(0, ccvm.goalsToGo)
    }

    func testRemoveChapterGoals() throws {
        let goals = goalTexts.map {
            context.addGoal($0)
        }

        for (idx, goal) in goals.enumerated() {
            XCTAssertTrue(ccvm.add(goal: goal))
            XCTAssertEqual(4 - idx, ccvm.goalsToGo)
        }

        for (idx, goal) in goals.enumerated() {
            XCTAssertEqual(idx, ccvm.goalsToGo)
            ccvm.remove(goal: goal)
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
        XCTAssertFalse(ccvm.createdChapter)
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

        XCTAssertTrue(ccvm.createdChapter)
    }
}

// MARK: - Drag and drop to reorder chapter goals support
extension ChapterCreatorViewModelTests {
    func testGoalsMoveHandler() throws {
        let goal1 = context.addGoal("some text")
        let goal2 = context.addGoal("some text 2")
        let goal3 = context.addGoal("some text 3")

        ccvm.add(goal: goal1)
        ccvm.add(goal: goal2)
        ccvm.add(goal: goal3)

        XCTAssertEqual([goal1, goal2, goal3], ccvm.chapterGoals)
        ccvm.moveChapterGoals(from: .init(integer: 0), to: 3)
        XCTAssertEqual([goal2, goal3, goal1], ccvm.chapterGoals)
        ccvm.moveChapterGoals(from: .init(integer: 0), to: 2)
        XCTAssertEqual([goal3, goal2, goal1], ccvm.chapterGoals)
    }
}

// MARK: - Chapter creation assertions
extension ChapterCreatorViewModelTests {
    func testCreatingAChapterMustChangeAttributesTitle() throws {
        let testTitle = "A Title"
        ccvm.title = testTitle
        for goalTxt in goalTexts {
            ccvm.goalText = goalTxt
            ccvm.createGoal()
        }
        ccvm.createChapter()
        XCTAssertEqual(1, try context.count(for: Chapter.fetchRequest()))
        guard let firstChapter = try context.fetch(Chapter.fetchRequest()).first else {
            return XCTFail("there should be one chapter at least")
        }
        XCTAssertNotNil(firstChapter.dateStarted)

        // Show attributes must change to create new chapters
        let ccvm2 = ChapterCreatorViewModel(context)
        XCTAssertEqual(testTitle, ccvm2.title)
        XCTAssertEqual(ccvm2.chapterGoals.count, goalTexts.count)
        for (idx, goal) in ccvm2.chapterGoals.enumerated() {
            let goalText = goalTexts[idx]
            XCTAssertEqual(goal.title, goalText)
        }

        ccvm2.createChapter()
        XCTAssertEqual(1, try context.count(for: Chapter.fetchRequest()))
        XCTAssertEqual(ccvm2.actionAlert, .duplicateChapterAlert)
        ccvm2.actionAlert = nil

        let updatedTitle = "Updated Title"
        ccvm2.title = "Updated Title"
        ccvm2.createChapter()

        let persistedChapters = try context.fetch(Chapter.fetchRequest())
        XCTAssertEqual(1, persistedChapters.count)
        XCTAssertEqual(updatedTitle, persistedChapters.first?.title)
    }

    func testCreatingAChapterMustChangeAttributesGoals() throws {
        let testTitle = "A Title"
        ccvm.title = testTitle
        for goalTxt in goalTexts {
            ccvm.goalText = goalTxt
            ccvm.createGoal()
        }
        ccvm.createChapter()
        XCTAssertEqual(1, try context.count(for: Chapter.fetchRequest()))
        guard let firstChapter = try context.fetch(Chapter.fetchRequest()).first else {
            return XCTFail("there should be one chapter at least")
        }
        XCTAssertNotNil(firstChapter.dateStarted)

        let ccvm3 = ChapterCreatorViewModel(context)
        XCTAssertEqual(testTitle, ccvm3.title)
        XCTAssertEqual(ccvm3.chapterGoals.count, goalTexts.count)
        for (idx, goal) in ccvm3 .chapterGoals.enumerated() {
            let goalText = goalTexts[idx]
            XCTAssertEqual(goal.title, goalText)
        }

        guard let firstGoal = ccvm3.chapterGoals.first else {
            return XCTFail("There should be a goal in the newly created ccvm automatically")
        }
        firstGoal.title = "new goal title"
        try context.save()
        ccvm3.createChapter()
        XCTAssertEqual(ccvm3.actionAlert, .duplicateChapterAlert)

        let aRealNewGoal = context.addGoal("new new new")
        ccvm3.remove(goal: firstGoal)
        ccvm3.add(goal: aRealNewGoal)
        ccvm3.createChapter()

        let persistedChapters = try context.fetch(Chapter.fetchRequest())
        XCTAssertEqual(1, persistedChapters.count)
        XCTAssertEqual(testTitle, persistedChapters.first?.title)
        let goals = persistedChapters.first?.chapterGoals?
            .compactMap { $0 as? ChapterGoal }
            .compactMap { $0.goal }

        XCTAssertTrue(goals?.contains([aRealNewGoal]) ?? false, "the newly created chapter should have the new goal")
    }

    func testCreatingAChapterFromOldChapterWithPagesThatWereNotDraft() throws {
        ccvm.title = "A Title"
        for goalTxt in goalTexts {
            ccvm.goalText = goalTxt
            ccvm.createGoal()
        }
        ccvm.createChapter()
        XCTAssertEqual(1, try context.count(for: Chapter.fetchRequest()))

        guard let firstChapter = (try context.fetch(Chapter.fetchRequest())).first else {
            return XCTFail("There should be a chapter")
        }
        let page = Page(context: context)
        page.chapter = firstChapter
        page.isDraft = false
        try context.save()

        XCTAssertNil(firstChapter.dateEnded)
        // Demostrate old chapter does not get destroyed and end date is populated
        let ccvm2 = ChapterCreatorViewModel(context)
        ccvm2.title = "A slightly different title to make this valid"
        ccvm2.createChapter()

        XCTAssertEqual(2, try context.count(for: Chapter.fetchRequest()))
        XCTAssertNotNil(firstChapter.dateEnded)
        XCTAssertFalse(try context.fetch(Page.fetchRequest()).first?.isDraft ?? true)
    }

    func testCreatingAChapterFromOldChapterWithPagesThatHadADraftPage() throws {
        ccvm.title = "A Title"
        for goalTxt in goalTexts {
            ccvm.goalText = goalTxt
            ccvm.createGoal()
        }
        ccvm.createChapter()
        XCTAssertEqual(1, try context.count(for: Chapter.fetchRequest()))

        guard let firstChapter = (try context.fetch(Chapter.fetchRequest())).first else {
            return XCTFail("There should be a chapter")
        }
        let page = Page(context: context)
        page.chapter = firstChapter
        page.isDraft = true
        try context.save()

        XCTAssertNil(firstChapter.dateEnded)
        // Demostrate old chapter does not get destroyed and end date is populated
        let ccvm2 = ChapterCreatorViewModel(context)
        ccvm2.title = "A slightly different title to make this valid"
        ccvm2.createChapter()

        XCTAssertEqual(2, try context.count(for: Chapter.fetchRequest()))
        XCTAssertNotNil(firstChapter.dateEnded)
        XCTAssertFalse(try context.fetch(Page.fetchRequest()).first?.isDraft ?? true)
    }
}
