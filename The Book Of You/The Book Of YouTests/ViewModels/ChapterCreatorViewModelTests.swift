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
        XCTAssertFalse(persistedChapters.first?.isVacation ?? true)
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
        XCTAssertFalse(firstChapter.isVacation)

        let ccvm2 = ChapterCreatorViewModel(context)
        XCTAssertEqual(testTitle, ccvm2.title)
        XCTAssertFalse(ccvm2.isVacation)
        XCTAssertEqual(ccvm2.chapterGoals.count, goalTexts.count)
        for (idx, goal) in ccvm2 .chapterGoals.enumerated() {
            let goalText = goalTexts[idx]
            XCTAssertEqual(goal.title, goalText)
        }

        guard let firstGoal = ccvm2.chapterGoals.first else {
            return XCTFail("There should be a goal in the newly created ccvm automatically")
        }
        firstGoal.title = "new goal title"
        try context.save()
        ccvm2.createChapter()
        XCTAssertEqual(ccvm2.actionAlert, .duplicateChapterAlert)

        let aRealNewGoal = context.addGoal("new new new")
        ccvm2.remove(goal: firstGoal)
        ccvm2.add(goal: aRealNewGoal)
        ccvm2.createChapter()

        let persistedChapters = try context.fetch(Chapter.fetchRequest())
        XCTAssertEqual(1, persistedChapters.count)
        XCTAssertEqual(testTitle, persistedChapters.first?.title)
        XCTAssertFalse(persistedChapters.first?.isVacation ?? false)
        let goals = persistedChapters.first?.chapterGoals?
            .compactMap { $0 as? ChapterGoal }
            .compactMap { $0.goal }

        XCTAssertTrue(goals?.contains([aRealNewGoal]) ?? false, "the newly created chapter should have the new goal")
    }

    func testCreatingAChapterFromAVacationChapterMustChangeTitle() throws {
        let testTitle = "A Title"
        ccvm.title = testTitle
        ccvm.isVacation = true
        ccvm.createChapter()
        XCTAssertEqual(1, try context.count(for: Chapter.fetchRequest()))
        guard let firstChapter = try context.fetch(Chapter.fetchRequest()).first else {
            return XCTFail("there should be one chapter at least")
        }
        XCTAssertNotNil(firstChapter.dateStarted)
        XCTAssertTrue(firstChapter.isVacation)

        let ccvm2 = ChapterCreatorViewModel(context)
        XCTAssertEqual(testTitle, ccvm2.title)
        XCTAssertTrue(ccvm2.isVacation)
        XCTAssertEqual(ccvm2.chapterGoals.count, 0)
        ccvm2.createChapter()
        XCTAssertEqual(ccvm2.actionAlert, .duplicateChapterAlert)

        ccvm2.title = "updated"
        ccvm2.createChapter()

        let persistedChapters = try context.fetch(Chapter.fetchRequest())
        XCTAssertEqual(1, persistedChapters.count)
        XCTAssertEqual("updated", persistedChapters.first?.title)
        XCTAssertTrue(persistedChapters.first?.isVacation ?? false)
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
