//
//  PageValidatorTestCase.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 5/1/23.
//

import XCTest
@testable import The_Book_Of_You

final class PageValidatorTestCase: BackgroundContextTestCase {
    private var page: Page!
    private var validator: PageValidator!
    private var pageEntriesValidator: FakePageEntriesValidator!

    override func setUp() async throws {
        try await super.setUp()
        page = Page(context: context)
        pageEntriesValidator = .init(TextEntryValidator())
        validator = PageValidator(pageEntriesValidator)

        page.pageEntries = NSSet()
        page.vacationDay = false
        page.entryDate = .now
        page.lastModifiedAt = .now
    }

    func testTimeStampValidation() {
        XCTAssertEqual(validator.validate(page), .success(true))
        page.entryDate = nil
        XCTAssertEqual(validator.validate(page), .failure(.fieldErrors([.entryDateError])))
        page.entryDate = .now
        XCTAssertEqual(validator.validate(page), .success(true))
        page.lastModifiedAt = nil
        XCTAssertEqual(validator.validate(page), .failure(.fieldErrors([.lastModifedAtError])))
        page.lastModifiedAt = .now
        XCTAssertEqual(validator.validate(page), .success(true))
        page.lastModifiedAt = nil
        page.entryDate = nil
        XCTAssertEqual(validator.validate(page), .failure(.fieldErrors([.entryDateError, .lastModifedAtError])))

    }

    func testVacationDay() {
        XCTAssertEqual(validator.validate(page), .success(true))
        page.vacationDay = true
        page.journalEntry = nil
        XCTAssertEqual(validator.validate(page), .failure(.fieldErrors([.blankJournalOnVacationDay])))
        page.vacationDay = true
        page.journalEntry = ""
        XCTAssertEqual(validator.validate(page), .failure(.fieldErrors([.blankJournalOnVacationDay])))
        page.vacationDay = true
        page.journalEntry = " \t"
        XCTAssertEqual(validator.validate(page), .failure(.fieldErrors([.blankJournalOnVacationDay])))
        page.vacationDay = true
        page.journalEntry = " untrimmed text "
        XCTAssertEqual(validator.validate(page), .failure(.fieldErrors([.untrimmedJournalText])))
        page.journalEntry = "some text"
        XCTAssertEqual(validator.validate(page), .success(true))
    }

    func testPageEntries() {
        XCTAssertEqual(validator.validate(page), .success(true))
        pageEntriesValidator.mockResult = .failure(.unknownEntryTypeError)
        XCTAssertEqual(validator.validate(page),
            .failure(.fieldErrors([.pageEntriesValidationError(.unknownEntryTypeError)]))
        )

    }
}

final class PageValidationErrorTest: BackgroundContextTestCase {
    private var page: Page!
    private var pageEntry: PageEntry!
    private var pageEntry2: PageEntry!
    private var pageValidationError: PageValidationError!

    override func setUp() async throws {
        try await super.setUp()
        page = context.addPage(goals: 2)
        // swiftlint:disable:next force_cast
        let pageEntries = page.pageEntries!.allObjects as! [PageEntry]
        pageEntry = pageEntries.first
        pageEntry2 = pageEntries.last
        pageValidationError = .fieldErrors([
            .entryDateError, .lastModifedAtError, .blankJournalOnVacationDay, .untrimmedJournalText,
            .pageEntriesValidationError(.entryValidation([pageEntry: [.textEntry(.emptyText)]]))
        ])
    }

    func testPageErrors() {
        XCTAssertEqual(pageValidationError.getPageErrors(),
                       [.entryDateError, .lastModifedAtError, .blankJournalOnVacationDay, .untrimmedJournalText])
    }

    func testPageEntryErrors() {
        XCTAssertEqual(pageValidationError.getErrorsFor(pageEntry: pageEntry), [.textEntry(.emptyText)])
    }
}
