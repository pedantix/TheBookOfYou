//
//  DateEntryViewViewModelTests.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 5/10/23.
//

import XCTest
@testable import The_Book_Of_You

final class DateEntryViewModelTests: BackgroundContextTestCase {
    private var page: Page!
    private var viewModel: DateEntryViewModel!

    override func setUp() async throws {
        try await super.setUp()
        page = context.addPage()
        viewModel = .init(page, context)
    }

    func testSaveDate() throws {
        let orginalDate = page.entryDate
        let newDate = Date.date(daysAgo: 10)
        XCTAssertNotEqual(orginalDate, newDate)
        XCTAssertEqual(viewModel.editorDate, orginalDate)
        viewModel.editorDate = newDate
        viewModel.saveDate()
        XCTAssertEqual(viewModel.editorDate, newDate)
        XCTAssertEqual(page.entryDate, newDate)
        XCTAssertFalse(context.hasChanges)
    }
}
