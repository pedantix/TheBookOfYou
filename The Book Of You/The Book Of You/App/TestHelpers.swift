//
//  TestHelpers.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 6/29/23.
//

import Foundation
import CloudStorage

struct AppTestHelper {
    @CloudStorage(.identityGoalsKey) private var goals = 5
    private func isUITest() -> Bool {
        return ProcessInfo.processInfo.environment["UI_TEST"] == "1"
    }

    func resetIfIsUITest() {
        guard isUITest() else { return appLogger.info("Not a UI Test, skipping reset") }
        appLogger.info("UI Test Confirmed")

        appLogger.info("Resetting CloudStorage info")
        goals = 5
    }
}
