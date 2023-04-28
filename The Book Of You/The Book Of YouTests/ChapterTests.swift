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
