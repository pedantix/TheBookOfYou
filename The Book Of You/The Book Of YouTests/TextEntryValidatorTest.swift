//
//  TextEntryValidatorTest.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 5/1/23.
//

import XCTest
@testable import The_Book_Of_You

final class TextEntryValidatorTest: BackgroundContextTestCase {
    private var textEntry: TextEntry!
    private var validator: TextEntryValidator!

    override func setUp() async throws {
        try await super.setUp()
        textEntry = TextEntry(context: context)
        validator = TextEntryValidator()
    }

    func testValidateWithNilText() throws {
        switch validator.validate(textEntry) {
        case .failure(.emptyText):
            break
        default:
            XCTFail("This is not the expected case")
        }
    }

    func testValidateWithEmptyText() throws {
        textEntry.text = ""
        switch validator.validate(textEntry) {
        case .failure(.emptyText):
            break
        default:
            XCTFail("This is not the expected case")
        }
    }

    func testValidateWithBlankText() throws {
        textEntry.text = " \t \n "
        switch validator.validate(textEntry) {
        case .failure(.emptyText):
            break
        default:
            XCTFail("This is not the expected case")
        }
    }

    func testValidateWithSomeTextThatHasUntrimmedWhiteSpace() throws {
        textEntry.text = " some text  "

        switch validator.validate(textEntry) {
        case .failure(.untrimmedText):
            break
        default:
            XCTFail("This is not the expected case")
        }
    }

    func testValidateWithSomeText() throws {
        textEntry.text = " some text  ".trimmed

        XCTAssertNoThrow(validator.validate(textEntry))

        switch validator.validate(textEntry) {
        case .success:
            break
        case .failure:
            XCTFail("Failure is unexpected")
        }
    }
}
