//
//  Chapter.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/19/23.
//

import CoreData

extension Chapter {
    class func currentChapter() -> NSFetchRequest<Chapter> {
        let fetchReq = Chapter.allChaptersSorted()
        fetchReq.fetchLimit = 1
        return  fetchReq
    }

    class func allPastChapters() -> NSFetchRequest<Chapter> {
        let fetchReq = Chapter.allChaptersSorted()
        fetchReq.fetchOffset = 1
        return fetchReq
    }

    class func allChaptersSorted() -> NSFetchRequest<Chapter> {
        let fetchReq = Chapter.fetchRequest()
        fetchReq.sortDescriptors = [NSSortDescriptor(keyPath: \Chapter.dateStarted, ascending: false)]
        return fetchReq
    }
}

extension Chapter {
    var pageCount: Int {
        return pages?.count ?? 0
    }

    var goals: [Goal] {
        return chapterGoals?
            .compactMap { $0 as? ChapterGoal }
            .sorted(using: SortDescriptor(\ChapterGoal.orderIdx))
            .compactMap { $0.goal } ?? []
    }

    /// Returns true if chapters are equivalent for user experience
    func compare(with other: Chapter?) -> Bool {
        // skip non existent chapter
        guard let anotherChapter = other else { return false }
        // different titles or goals presence validates
        if title == anotherChapter.title && goals == anotherChapter.goals {
            return true
        }
        // Not the same
        return false
    }
}
