//
//  PageTestCases.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 5/14/23.
//

import XCTest
@testable import The_Book_Of_You

final class PageTestCases: BackgroundContextTestCase {

    func testEmptyPublishedPages() throws {
        let chapter = context.addChapter()
        context.addPage(to: chapter, isDraft: true)
        let fetchedPages = try context.fetch(Page.publishedPages(for: chapter)) as [Page]

        XCTAssertEqual(fetchedPages, [])
    }

    func testPublishedPagesForChapterWithoutADraft() throws {
        let chapter = context.addChapter()
        let pageFiveDaysAgo = context.addPage(to: chapter, daysAgo: 5)
        let pagefourDaysAgo = context.addPage(to: chapter, daysAgo: 4)
        let pageOneDayAgo = context.addPage(to: chapter, daysAgo: 1)
        let todayPage = context.addPage(to: chapter, daysAgo: 0)
        let otherChapter = context.addChapter()
        context.addPage(to: otherChapter, isDraft: false)
        let fetchedPages = try context.fetch(Page.publishedPages(for: chapter)) as [Page]

        XCTAssertEqual(fetchedPages, [todayPage, pageOneDayAgo, pagefourDaysAgo, pageFiveDaysAgo])
    }

    func testPublishedPagesForChapterWithADraft() throws {
        let chapter = context.addChapter()
        let pageFiveDaysAgo = context.addPage(to: chapter, daysAgo: 5)
        let pagefourDaysAgo = context.addPage(to: chapter, daysAgo: 4)
        let pageOneDayAgo = context.addPage(to: chapter, daysAgo: 1)
        context.addPage(to: chapter, isDraft: true, daysAgo: 0)

        let otherChapter = context.addChapter()
        context.addPage(to: otherChapter, isDraft: false)
        let fetchedPages = try context.fetch(Page.publishedPages(for: chapter)) as [Page]

        XCTAssertEqual(fetchedPages, [pageOneDayAgo, pagefourDaysAgo, pageFiveDaysAgo])
    }

    func testDraftPageForChapterWithoutADraft() throws {
        let chapter = context.addChapter()
        context.addPage(to: chapter, isDraft: false)

        let otherChapter = context.addChapter()
        context.addPage(to: otherChapter, isDraft: true)
        let fetchedPages = try context.fetch(Page.draftPages(for: chapter)) as [Page]
        XCTAssertNil(fetchedPages.first)
    }

    func testDraftPageForChapterWithADraft() throws {
        let chapter = context.addChapter()
        context.addPage(to: chapter, isDraft: false)
        let page = context.addPage(to: chapter, isDraft: true)
        let otherChapter = context.addChapter()
        context.addPage(to: otherChapter, isDraft: true)

        let fetchedPages = try context.fetch(Page.draftPages(for: chapter)) as [Page]
        XCTAssertEqual(fetchedPages.first, page)
        XCTAssertEqual(fetchedPages.last, page)
    }
}
