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
