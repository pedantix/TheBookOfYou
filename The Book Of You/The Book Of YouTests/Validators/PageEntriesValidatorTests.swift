//
//  PageEntriesValidatorTests.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 5/1/23.
//

import XCTest
@testable import The_Book_Of_You

final class PageEntriesValidatorTests: BackgroundContextTestCase {
    private var entryOrder = Int64(0)
    private var validator: PageEntriesValidator!

    override func setUp() async throws {
        try await super.setUp()
        validator = PageEntriesValidator(.init())
    }

    func testValidCase() throws {
        let validEntry = createValidTextEntryPageEntry()
        let validEntry2 = createValidTextEntryPageEntry()
        let nsSet = NSSet(array: [validEntry, validEntry2])
        XCTAssertEqual(validator.validate(nsSet), .success(true))
    }

    func testInvalidCaseIdxIsSet() throws {
        let validEntry = createValidTextEntryPageEntry()
        let invalidEntry = createInvalidTextEntryPageEntry()
        let nsSet = NSSet(array: [validEntry, invalidEntry])
        let result = validator.validate(nsSet)
        switch result {
        case .failure(.entryValidation(let dict)):
            XCTAssertEqual([invalidEntry: [.textEntry(.emptyText)]], dict)
        default:
            XCTFail("This result \(result) is not under test")
        }
    }

    func testMissingOrder() throws {
        let validEntry = createValidTextEntryPageEntry()
        validEntry.entryOrder = 0
        let validEntry2 = createValidTextEntryPageEntry()
        validEntry2.entryOrder = 0
        let nsSet = NSSet(array: [validEntry, validEntry2])

        let result = validator.validate(nsSet)
        switch result {
        case .failure(.invalidOrderSequence):
            break
        default:
            XCTFail("This result \(result) is not under test")
        }
    }

    private func getEntryOrderAndIncrement() -> Int64 {
        defer { entryOrder += 1 }
        return entryOrder
    }

    private func createValidTextEntryPageEntry() -> PageEntry {
        let pageEntry = PageEntry(context: context)
        pageEntry.textEntry = TextEntry(context: context)
        pageEntry.textEntry?.text = "Valid text"
        pageEntry.entryOrder = getEntryOrderAndIncrement()
        return pageEntry
    }

    private func createInvalidTextEntryPageEntry() -> PageEntry {
        let pageEntry = PageEntry(context: context)
        pageEntry.textEntry = TextEntry(context: context)
        pageEntry.entryOrder = getEntryOrderAndIncrement()
        return pageEntry
    }
}
