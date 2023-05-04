//
//  PageCreatorService.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 5/3/23.
//

import CoreData

class PageCreatorService {
    let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }

    func createPage(for chapter: Chapter) throws -> Page {
        let page = Page(context: viewContext)
        page.entryDate = .now
        page.lastModifiedAt = .now
        page.chapter = chapter

        if chapter.isVacation {
            page.vacationDay = true
        } else {
            for chapterGoal in chapter.chapterGoals?
                .compactMap({ $0 as? ChapterGoal }) ?? [] {
                let pageEntry = PageEntry(context: viewContext)
                pageEntry.entryOrder = chapterGoal.orderIdx
                pageEntry.page = page
                pageEntry.textEntry = TextEntry(context: viewContext)
            }
        }

        try viewContext.save()
        return page
    }
}
