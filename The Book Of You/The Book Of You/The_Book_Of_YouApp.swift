//
//  The_Book_Of_YouApp.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 3/29/23.
//

import SwiftUI

@main
struct The_Book_Of_YouApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            AppView()
            //ContentView()
              //  .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
