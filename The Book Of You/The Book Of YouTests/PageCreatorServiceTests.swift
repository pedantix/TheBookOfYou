//
//  PageCreatorServiceTests.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 5/3/23.
//

import XCTest
@testable import The_Book_Of_You

final class PageCreatorServiceTests: BackgroundContextTestCase {
    private var chapter: Chapter!
    private var vacationChapter: Chapter!
    private var pageCreatorSerivce: PageCreatorService!

    override func setUp() async throws {
        try await super.setUp()
        chapter = Chapter(context: context)
        context.addGoal("1", with: chapter)
        context.addGoal("2", with: chapter)

        vacationChapter = Chapter(context: context)
        vacationChapter.isVacation = true
        pageCreatorSerivce = .init(viewContext: context)
    }

    func testCreatesAValidPageForVacationChapter() throws {
        let newPage = try pageCreatorSerivce.createPage(for: vacationChapter)
        XCTAssertEqual(newPage.pageEntries?.count, 0)
        XCTAssertTrue(newPage.vacationDay)
        XCTAssertNotNil(newPage.entryDate)
        XCTAssertNotNil(newPage.lastModifiedAt)
        XCTAssertTrue(newPage.isDraft)
        XCTAssertEqual(1, try context.count(for: Page.fetchRequest()))
        XCTAssertEqual(newPage.chapter, vacationChapter)
    }

    func testCreateAValdidPageForChapterWithTwoGoals() throws {
        let newPage = try pageCreatorSerivce.createPage(for: chapter)
        XCTAssertNotNil(newPage.pageEntries)

        if let pageEntries = newPage.pageEntries?.compactMap({ $0 as? PageEntry }), pageEntries.count == 2 {
            var orderIndicies = Set<Int64>()
            for pageEntry in pageEntries {
                XCTAssertTrue(orderIndicies.insert(pageEntry.entryOrder).inserted)
                XCTAssertNotNil(pageEntry.textEntry)
            }
        } else {
            XCTFail("page entries are not set up as expected")
        }

        XCTAssertTrue(newPage.isDraft)
        XCTAssertFalse(newPage.vacationDay)
        XCTAssertNotNil(newPage.entryDate)
        XCTAssertNotNil(newPage.lastModifiedAt)
        XCTAssertEqual(1, try context.count(for: Page.fetchRequest()))
        XCTAssertEqual(newPage.chapter, chapter)
    }
}
