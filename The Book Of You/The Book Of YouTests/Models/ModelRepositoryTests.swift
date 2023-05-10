//
//  ModelRepositoryTests.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 5/9/23.
//

import XCTest
@testable import The_Book_Of_You

final class ModelRepositoryTests: BackgroundContextTestCase {
    private var page: Page!
    private var chapter: Chapter!
    private var modelRepo: (any ModelRepo)!

    override func setUp() async throws {
        try await super.setUp()

        modelRepo = ModelRepository(context, persistentStoreCoordinator)
        page = context.addVacationPage()
        chapter = context.addChapter()
        context.addChapters()
        context.addPages(to: chapter)
    }

    func testFetchPage() throws {
        XCTAssertNotEqual(1, try context.count(for: Page.fetchRequest()))

        let fetchedPage = try modelRepo.fetchPage(by: page.objectID.uriRepresentation())
        XCTAssertEqual(page, fetchedPage)
    }

    func testFetchChapter() throws {
        XCTAssertNotEqual(1, try context.count(for: Chapter.fetchRequest()))

        let fetched = try modelRepo.fetchChapter(by: chapter.objectID.uriRepresentation())
        XCTAssertEqual(chapter, fetched)
    }
}
