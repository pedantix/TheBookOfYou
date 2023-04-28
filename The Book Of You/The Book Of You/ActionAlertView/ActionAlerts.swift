//
//  ActionAlerts.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/28/23.
//

import Foundation

extension ActionAlertData {
    static func persistenceAlert(_ error: NSError) -> ActionAlertData {
        return .init(
            title: "Error With Persistence",
            message: "There was an error saving context \(error).\n" +
            "Localized Description: \(error.localizedDescription).\n UserInfo: \(error.userInfo)",
            sfSymbolText: "gear.badge.questionmark"
        )
    }
}
