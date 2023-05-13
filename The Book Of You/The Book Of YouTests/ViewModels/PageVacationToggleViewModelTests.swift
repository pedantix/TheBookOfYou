//
//  PageVacationToggleViewModelTests.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 5/13/23.
//

import XCTest
@testable import The_Book_Of_You

final class PageVacationToggleViewModelTests: BackgroundContextTestCase {
    private var page: Page!
    private var viewModel: PageVacationToggleViewModel!

    override func setUp() async throws {
        try await super.setUp()
        page = context.addPage()
        viewModel = .init(page, context)
    }

    func testSaveDate() throws {
        XCTAssertFalse(page.vacationDay)
        viewModel.isVacationDay = false
        XCTAssertFalse(page.vacationDay)
        XCTAssertFalse(context.hasChanges)
        viewModel.isVacationDay = true
        viewModel.saveDate()
        XCTAssertTrue(page.vacationDay)
        XCTAssertTrue(viewModel.isVacationDay)
        XCTAssertFalse(context.hasChanges)
    }
}
