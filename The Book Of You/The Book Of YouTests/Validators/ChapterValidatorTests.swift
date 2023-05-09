//
//  ChapterValidatorTests.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 5/8/23.
//

import XCTest
@testable import The_Book_Of_You

class ChapterValidatorTests: BackgroundContextTestCase {
    private var validChapter: Chapter!
    private var validVacationChapter: Chapter!
    private var chapterWithThreeGoals: Chapter!
    private var chapterWithEmptyTitle: Chapter!
    private var validator: ChapterValidator!

    override func setUp() async throws {
        try await super.setUp()

        validChapter = context.addChapter(goals: 5)
        chapterWithThreeGoals = context.addChapter(goals: 3)
        chapterWithEmptyTitle = context.addChapter(goals: 5)
        validVacationChapter = context.addVacationChapter()
        chapterWithEmptyTitle.title = ""
        validator = await .init()
    }

    func testValidCase() {
        XCTAssertEqual(validator.validate(validChapter), .success(true))
        XCTAssertEqual(validator.validate(validVacationChapter), .success(true))
    }

    func testBlankTitle() {
        XCTAssertEqual(validator.validate(chapterWithEmptyTitle), .failure(.init(fieldErrors: [.blankTitle])))

        chapterWithEmptyTitle.title = " "

        XCTAssertEqual(validator.validate(chapterWithEmptyTitle), .failure(.init(fieldErrors: [.blankTitle])))

        chapterWithEmptyTitle.title = " \n "

        XCTAssertEqual(validator.validate(chapterWithEmptyTitle), .failure(.init(fieldErrors: [.blankTitle])))

        chapterWithEmptyTitle.title = " \t \n "
        XCTAssertEqual(validator.validate(chapterWithEmptyTitle), .failure(.init(fieldErrors: [.blankTitle])))
    }

    func testUntrimmedTitle() {
        chapterWithEmptyTitle.title = " asdf "

        XCTAssertEqual(validator.validate(chapterWithEmptyTitle), .failure(.init(fieldErrors: [.untrimmedTitle])))

        chapterWithEmptyTitle.title = " \nasdf "

        XCTAssertEqual(validator.validate(chapterWithEmptyTitle), .failure(.init(fieldErrors: [.untrimmedTitle])))

        chapterWithEmptyTitle.title = " \tasdf \n "
        XCTAssertEqual(validator.validate(chapterWithEmptyTitle), .failure(.init(fieldErrors: [.untrimmedTitle])))
    }

    func testTooFewGoals() {
        XCTAssertEqual(validator.validate(chapterWithThreeGoals), .failure(.init(fieldErrors: [.tooFewGoals])))
    }

    func testMultipleErrors() {
        chapterWithThreeGoals.title = " "
        XCTAssertEqual(
            validator.validate(chapterWithThreeGoals),
            .failure(.init(fieldErrors: [.blankTitle, .tooFewGoals]))
        )
    }
}
