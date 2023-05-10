//
//  NavStoreTests.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 5/10/23.
//

import SwiftUI
import XCTest
@testable import The_Book_Of_You

final class NavStoreTests: XCTestCase {
    private var navStore: NavStore!
    private var testPath: NavigationPath!
    override func setUp() async throws {
        try await super.setUp()
        navStore = await NavStore()
        testPath = NavigationPath()
    }

    func testNavigateToDestination() async throws {
        await compareToCurrentStorePath(isEqual: true)

        await navStore.navigate(to: .about)
        await compareToCurrentStorePath(isEqual: false)
        testPath.append(Destination.about)
        await compareToCurrentStorePath(isEqual: true)
    }

    func testPopBack() async throws {
        await compareToCurrentStorePath(isEqual: true)
        await navStore.navigate(to: .about)
        await compareToCurrentStorePath(isEqual: false)
        await navStore.popBack()
        await compareToCurrentStorePath(isEqual: true)
    }

    func testPopAndNavigate() async throws {
        await navStore.navigate(to: .about)
        testPath.append(Destination.intro)
        await compareToCurrentStorePath(isEqual: false)
        await navStore.popAndNavigate(to: .intro)
        await compareToCurrentStorePath(isEqual: true)
    }

    func compareToCurrentStorePath(isEqual: Bool) async {
        let currentPath = await navStore.path
        if isEqual {
            XCTAssertEqual(currentPath, testPath)
        } else {
            XCTAssertNotEqual(currentPath, testPath)
        }
    }
}
