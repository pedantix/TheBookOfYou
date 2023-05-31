//
//  LaunchScenario.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/30/23.
//

import Foundation

// The following is to fascilitate with UI Testing
enum LaunchScenario: String {
    case application
    case blankSlate
    case sixGoals
}

extension LaunchScenario {
    static let ScenarioKey = "Scenario"
    static var current: LaunchScenario {
        let scenarioTxt = ProcessInfo().environment[ScenarioKey] ?? ""
        if let aScenario = LaunchScenario(rawValue: scenarioTxt) {
            return aScenario
        }
        return .application
    }
}
