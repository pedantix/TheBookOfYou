//
//  ChapterTests.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 4/19/23.
//

import XCTest
import CoreData
@testable import The_Book_Of_You

final class ChapterTests: BackgroundContextTestCase {
    private var testChapters: [Chapter]!

    override func setUp() async throws {
        try await super.setUp()

        let da3chap = context.makeChapter(daysAgo: 3)
        let presentChapter = context.makeChapter(daysAgo: 0)
        let da2chap = context.makeChapter(daysAgo: 2)
        let da1chap = context.makeChapter(daysAgo: 1)

        testChapters = [presentChapter, da1chap, da2chap, da3chap]
    }

    func testAllChaptersSorted() throws {
        expectation(forNotification: .NSManagedObjectContextDidSave, object: context) { _ in
            return true
        }
        try context.save()

        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Save failed to trigger")
        }

        let sortedChapters = try context.fetch(Chapter.allChaptersSorted()) as [Chapter]
        let allChapters = try context.fetch(Chapter.fetchRequest())

        XCTAssertEqual(4, sortedChapters.count)
        XCTAssertEqual(testChapters, sortedChapters)
        XCTAssertEqual(4, allChapters.count)
    }

    func testFirstChapter() throws {
        expectation(forNotification: .NSManagedObjectContextDidSave, object: context) { _ in
            return true
        }
        try context.save()

        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Save failed to trigger")
        }

        let chapters = try context.fetch(Chapter.currentChapter()) as [Chapter]
        let allChapters = try context.fetch(Chapter.fetchRequest())

        XCTAssertEqual(1, chapters.count)
        XCTAssertEqual([testChapters[0]], chapters)
        XCTAssertEqual(4, allChapters.count)
    }

    func testAllPastChapters() throws {
        expectation(forNotification: .NSManagedObjectContextDidSave, object: context) { _ in
            return true
        }
        try context.save()

        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Save failed to trigger")
        }

        let chapters = try context.fetch(Chapter.allPastChapters()) as [Chapter]
        let allChapters = try context.fetch(Chapter.fetchRequest())

        XCTAssertEqual(3, chapters.count)
        XCTAssertEqual(testChapters[1...], chapters[0...])
        XCTAssertEqual(4, allChapters.count)
    }
}

// MARK: - Comparison tests
extension ChapterTests {
    func testComparison() throws {
        let chapter1 = Chapter(context: context)
        let chapter2 = Chapter(context: context)

        XCTAssertTrue(chapter1.compare(with: chapter2))

        let title = "a title"
        chapter1.title = title
        chapter2.title = "nope"

        XCTAssertFalse(chapter1.compare(with: chapter2))
        chapter2.title = title
        XCTAssertTrue(chapter1.compare(with: chapter2))

        let goal1 = Goal(context: context)
        goal1.title = "a title"
        let goal2 = Goal(context: context)
        goal2.title = "other title"

        for (idx, goal) in [goal1, goal2].enumerated() {
            let chapGoal = ChapterGoal(context: context)
            chapGoal.chapter = chapter1
            chapGoal.orderIdx = Int64(idx)
            chapGoal.goal = goal
        }
        try context.save()

        XCTAssertFalse(chapter1.compare(with: chapter2))

        for (idx, goal) in [goal1, goal2].enumerated() {
            let chapGoal = ChapterGoal(context: context)
            chapGoal.chapter = chapter2
            chapGoal.orderIdx = Int64(idx)
            chapGoal.goal = goal
        }
        try context.save()

        XCTAssertTrue(chapter1.compare(with: chapter2))
    }

    func testPageCount() throws {
        let chapter = Chapter(context: context)
        XCTAssertEqual(0, chapter.pageCount)

        let page = Page(context: context)
        page.chapter = chapter
        try context.save()
        XCTAssertEqual(1, chapter.pageCount)
    }
}
