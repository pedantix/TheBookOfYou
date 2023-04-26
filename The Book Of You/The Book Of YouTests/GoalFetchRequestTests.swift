//
//  GoalFetchRequestTests.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 4/23/23.
//

import XCTest
import Fakery
@testable import The_Book_Of_You

final class GoalFetchRequestTests: BackgroundContextTestCase {

    let faker = Faker(locale: "en_US")

    func testGoalsSortsAlphabeticallyDescending() throws {
        let nbcGoal = try createFakeGoal(with: "nbc")
        let zbdGoal = try createFakeGoal(with: "zbd")
        let tviGoal = try createFakeGoal(with: "tvi")
        let abcGoal = try createFakeGoal(with: "abc")
        let spcaGoal = try createFakeGoal(with: "spca")
        let cbsGoal = try createFakeGoal(with: "cbs")

        let goals = try context.fetch(Goal.goals(notIn: [])) as [Goal]
        XCTAssertEqual(6, goals.count)

        XCTAssertEqual([abcGoal, cbsGoal, nbcGoal, spcaGoal, tviGoal, zbdGoal], goals)

    }

    func testThatGoalsNotInRemovesUnwantedGoalse() throws {
        let nbcGoal = try createFakeGoal(with: "nbc")
        let zbdGoal = try createFakeGoal(with: "zbd")
        let tviGoal = try createFakeGoal(with: "tvi")
        let abcGoal = try createFakeGoal(with: "abc")
        let spcaGoal = try createFakeGoal(with: "spca")
        let cbsGoal = try createFakeGoal(with: "cbs")

        let hobbitGoals = [try createFakeGoal(), try createFakeGoal(), try createFakeGoal()]

        let goals = try context.fetch(Goal.goals(notIn: hobbitGoals)) as [Goal]
        XCTAssertEqual(6, goals.count)

        XCTAssertEqual([abcGoal, cbsGoal, nbcGoal, spcaGoal, tviGoal, zbdGoal], goals)
    }

    func testThatGoalsNotInCanAlsoBeQueriedByString() throws {
        let nbcGoal = try createFakeGoal(with: "nbc")
        let zbdGoal = try createFakeGoal(with: "zbd")
        let tviGoal = try createFakeGoal(with: "tvi")
        let abcGoal = try createFakeGoal(with: "abc")
        let spcaGoal = try createFakeGoal(with: "spca")
        let cbsGoal = try createFakeGoal(with: "cbs")

        let hobbitGoals = [try createFakeGoal(), try createFakeGoal(), try createFakeGoal()]

        let goals = try context.fetch(Goal.goals(notIn: hobbitGoals, withTitleLike: "")) as [Goal]
        XCTAssertEqual(6, goals.count)

        XCTAssertEqual([abcGoal, cbsGoal, nbcGoal, spcaGoal, tviGoal, zbdGoal], goals)

        let goalFiltered = try context.fetch(Goal.goals(notIn: hobbitGoals, withTitleLike: "bc")) as [Goal]
        XCTAssertEqual(2, goalFiltered.count)

        XCTAssertEqual([abcGoal, nbcGoal], goalFiltered)

    }

    func testGoalsThatAreNamedReturnsOneAndOnlyOne() throws {
        let goalName = "dogs and cats"
        let fetchReq = Goal.goalsThatAre(named: goalName)

        XCTAssertEqual(0, (try context.fetch(fetchReq)).count)
        let pedingGoal = try createFakeGoal(with: goalName)

        XCTAssertEqual(1, (try context.fetch(fetchReq)).count)

        try createFakeGoal(with: goalName + "an")
        XCTAssertEqual(1, (try context.fetch(fetchReq)).count)
        XCTAssertEqual([pedingGoal], (try context.fetch(fetchReq)) as [Goal])

        let fr2 = Goal.goalsThatAre(named: " \(goalName) ")
        XCTAssertEqual([pedingGoal], (try context.fetch(fr2)) as [Goal])
    }

    func createFakeGoal() throws -> Goal {
        let goal = Goal(context: context)
        goal.title = faker.address.country()
        try context.save()
        return goal
    }

    @discardableResult
    func createFakeGoal(with name: String) throws -> Goal {
        let goal = Goal(context: context)
        goal.title = name
        try context.save()
        return goal
    }
}
