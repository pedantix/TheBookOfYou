//
//  XCUIApplication.swift
//  The Book Of YouUITests
//
//  Created by Shaun Hubbard on 6/29/23.
//

import XCTest

extension XCUIApplication {
    func launchUITestWithEnvironmentVariables(_ variables: [String: String] = [:]) {
        var defaultVariables = ["UI_TEST": "1"]
        defaultVariables.merge(variables, uniquingKeysWith: { (curent, _) in curent })
        launchEnvironment = defaultVariables
        launch()
    }
}
