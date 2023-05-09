//
//  ChapterEditorViewModelTests.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 5/9/23.
//

import XCTest
@testable import The_Book_Of_You

final class ChapterEditorViewModelTests: BackgroundContextTestCase {
    private var viewModel: ChapterEditorViewModel!
    private var chapter: Chapter!

    override func setUp() async throws {
        try await super.setUp()
        chapter = context.addVacationChapter()
        viewModel = .init(chapter, moc: context)
    }

    func testCannotSaveBlankOrEmptyTitle() {
        let originalTitle = chapter.title
        XCTAssertEqual(viewModel.editorTitle, originalTitle)
        XCTAssertNil(viewModel.alertData)
        viewModel.editorTitle = ""
        viewModel.saveChapter()
        XCTAssertEqual(chapter.title, originalTitle)
        XCTAssertEqual(viewModel.alertData, .blankChapterTitleAlert)
        viewModel.alertData = .none

        viewModel.editorTitle = " \t "
        viewModel.saveChapter()
        XCTAssertEqual(chapter.title, originalTitle)
        XCTAssertEqual(viewModel.alertData, .blankChapterTitleAlert)
        viewModel.alertData = .none

        viewModel.editorTitle = " \t\n "
        viewModel.saveChapter()
        XCTAssertEqual(chapter.title, originalTitle)
        XCTAssertEqual(viewModel.alertData, .blankChapterTitleAlert)
        viewModel.alertData = .none

        XCTAssertFalse(context.hasChanges)
        XCTAssertFalse(viewModel.didSave)
    }

    func testTitleIsSaveAndUpdatedWhenValidated() throws {
        let title = "A New Title"
        viewModel.editorTitle = " A New Title "
        viewModel.saveChapter()
        XCTAssertEqual(chapter.title, title)
        XCTAssertNil(viewModel.alertData)

        XCTAssertEqual(1, try context.count(for: Chapter.fetchRequest()))
        guard let fetchedChapter = try context.fetch(Chapter.fetchRequest()).first else {
            return XCTFail("At least one chapter should exist")
        }

        XCTAssertFalse(context.hasChanges)
        XCTAssertEqual(fetchedChapter.title, title)
        XCTAssertTrue(viewModel.didSave)
    }
}
