//
//  PageRowViewModelTests.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 5/8/23.
//

import XCTest
@testable import The_Book_Of_You

final class PageRowViewModelTests: BackgroundContextTestCase {
    private var page: Page!
    private var viewModel: PageRowViewModel!

    override func setUp() async throws {
        try await super.setUp()
        page = context.addPage()
        page.entryDate = Date(timeIntervalSinceReferenceDate: 118800)
        viewModel = .init(page: page)
    }

    func testEntryDate() throws {
        XCTAssertEqual(viewModel.entryDate, "Jan 2, 2001")
    }

    func testPageUrl() {
        XCTAssertEqual(page.objectID.uriRepresentation(), viewModel.pageUrl)
    }

    func testIsPageVacationDay() {
        XCTAssertFalse(viewModel.isVacation)
    }
}
