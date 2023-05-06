//
//  IndexChapterViewModelTests.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 4/20/23.
//

import XCTest
@testable import The_Book_Of_You

final class IndexChapterViewModelTests: BackgroundContextTestCase {
    private var chapter: Chapter!
    private var cvm: IndexChapterViewModel!

    override func setUp() async throws {
        try await super.setUp()
        chapter = Chapter(context: context)
        cvm = IndexChapterViewModel(chapter: chapter)
    }

    func testTitle() {
        XCTAssertEqual(cvm.title, "NO TITLE FOUND FOR RECORD")
        chapter.title = "dog"
        XCTAssertEqual(cvm.title, "dog")
    }

    func testStartDate() {
        let date = Date(timeIntervalSinceReferenceDate: 118800)
        XCTAssertEqual(cvm.startDate, "NO START DATE FOUND FOR RECORD")
        chapter.dateStarted = date
        XCTAssertEqual(cvm.startDate, "Jan 2, 2001")

    }

    func testEndDate() {
        let date = Date(timeIntervalSinceReferenceDate: 118800)
        XCTAssertEqual(cvm.endDate, "present")
        chapter.dateEnded = date
        XCTAssertEqual(cvm.endDate, "Jan 2, 2001")

    }

    func testChapterHeadingFromDateToPresent() {
        let date = Date(timeIntervalSinceReferenceDate: 118800)
        chapter.title = "dog"
        chapter.dateStarted = date
        XCTAssertEqual(cvm.chapterHeading, "dog - Jan 2, 2001 - present")
    }

    func testChapterHeadingFromStartDateToEndDate() {
        let date = Date(timeIntervalSinceReferenceDate: 118800)

        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: date)
        chapter.title = "dog"
        chapter.dateStarted = date
        chapter.dateEnded = endDate
        XCTAssertEqual(cvm.chapterHeading, "dog - Jan 2, 2001 - Jan 3, 2001")
    }

    func testDateBlockFromToPresent() {
        let date = Date(timeIntervalSinceReferenceDate: 118800)
        chapter.title = "dog"
        chapter.dateStarted = date
        XCTAssertEqual(cvm.dateBlock, "Jan 2, 2001 - present")
    }

    func testDateBlockFromToEndDate() {
        let date = Date(timeIntervalSinceReferenceDate: 118800)
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: date)
        chapter.title = "dog"
        chapter.dateStarted = date
        chapter.dateEnded = endDate
        XCTAssertEqual(cvm.dateBlock, "Jan 2, 2001 - Jan 3, 2001")
    }
}
