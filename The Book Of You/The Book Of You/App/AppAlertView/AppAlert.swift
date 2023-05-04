//
//  AppAlert.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/28/23.
//

import Foundation

struct AppAlert: Hashable {
    let title: String
    let message: String
    let sfSymbolText: String
}

extension AppAlert {
    static func persistenceAlert(_ error: NSError) -> AppAlert {
        return .init(
            title: "Error With Persistence",
            message: "There was an error saving context \(error).\n" +
            "Localized Description: \(error.localizedDescription).\n UserInfo: \(error.userInfo)",
            sfSymbolText: "gear.badge.questionmark"
        )
    }

    static let duplicateChapterAlert: AppAlert = AppAlert(
        title: "Duplicate Chapter Creation",
        message: "This chapter is materially identical to your last one; please change the title," +
        " goals, or another attribute. Editing goals will update all chapter" +
        " goals for cases of typos; please do this in the chapter editor.",
        sfSymbolText: "doc.on.doc"
    )

    static let maxGoalsAlert = AppAlert(
        title: "Not Added",
        message: "You have already reached the specified number of goals, " +
        "please remove one from the current chapter goals with a tap to add this goal with a tap." +
        " Or change your goal count in the Intro section.",
        sfSymbolText: "square.3.layers.3d.down.right.slash"
    )
}
