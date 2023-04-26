//
//  GoalViewModelTests.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 4/24/23.
//

import XCTest
@testable import The_Book_Of_You

final class GoalViewModelTests: BackgroundContextTestCase {
    func testTitle() throws {
        let goal = Goal(context: context)
        let gvm = GoalViewModel(goal: goal)
        XCTAssertEqual("BAD GOAL, NO TITLE", gvm.title)
        let goalTitle = "Be a Runner"
        goal.title = goalTitle
        XCTAssertEqual(goalTitle, gvm.title)
    }
}
