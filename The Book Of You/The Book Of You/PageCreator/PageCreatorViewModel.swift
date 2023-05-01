//
//  PageCreatorViewModel.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/30/23.
//

import CoreData

enum Entry {
    case text(Goal, TextEntry)
    case freeText(Page)
}

class PageCreatorViewModel: ObservableObject {
    init(_ context: NSManagedObjectContext =  PersistenceController.shared.viewContext) {
        moc = context
    }
    private let moc: NSManagedObjectContext

    @Published var entries: [Entry] = []
}
