//
//  Page.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 5/14/23.
//

import CoreData

extension Page {
    static func publishedPages(for chapter: Chapter) -> NSFetchRequest<Page> {
        let req = Page.fetchRequest()
        req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "isDraft == false"),
            NSPredicate(format: "chapter == %@", chapter)
        ])
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Page.entryDate, ascending: false)]
        return req
    }

    static func draftPages(for chapter: Chapter) -> NSFetchRequest<Page> {
        let req = Page.fetchRequest()
        req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "isDraft == true"),
            NSPredicate(format: "chapter == %@", chapter)
        ])
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Page.entryDate, ascending: false)]
        req.fetchLimit = 1
        return req
    }

}
