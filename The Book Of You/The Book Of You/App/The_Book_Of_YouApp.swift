//
//  The_Book_Of_YouApp.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 3/29/23.
//

import SwiftUI

// swiftlint:disable type_name
@main
struct The_Book_Of_YouApp: App {
// swiftlint:enable type_name
    var body: some Scene {
        lazy var persistenceController = PersistenceController.shared
        WindowGroup {
            AppView()
                .environment(\.managedObjectContext, PersistenceController.shared.viewContext)
        }
    }
}
