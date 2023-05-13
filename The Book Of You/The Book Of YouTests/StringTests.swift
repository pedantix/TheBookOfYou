//
//  StringTests.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 5/13/23.
//

import XCTest
@testable import The_Book_Of_You

final class StringTests: XCTestCase {
    func testIsBlank() {
        XCTAssertTrue("".isBlank)
        XCTAssertTrue(" ".isBlank)
        XCTAssertTrue("\t".isBlank)
        XCTAssertTrue("\t\n".isBlank)
        XCTAssertFalse("a".isBlank)
    }

    func testTrimmed() {
        XCTAssertEqual("", " \t\n ".trimmed)
        XCTAssertEqual("a", " \ta\n ".trimmed)
        XCTAssertEqual("a v", " \ta v\n ".trimmed)
    }
}
