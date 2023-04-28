//
//  Goal.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/23/23.
//

import CoreData

extension Goal {
    class func goals(notIn goals: [Goal], withTitleLike: String = "") -> NSFetchRequest<Goal> {
        let fetchReq = Goal.fetchRequest() as NSFetchRequest<Goal>
        var predicateArray = [NSPredicate(format: "NOT (SELF IN %@)", goals)]
        if !withTitleLike.isBlank {
            let trimmed = withTitleLike.trimmed
            let text = "*\(trimmed)*"
            predicateArray.append(NSPredicate(format: "title LIKE %@", text))
        }
        fetchReq.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
        fetchReq.sortDescriptors = [NSSortDescriptor(keyPath: \Goal.title, ascending: true)]
        return fetchReq
    }

    class func goalsThatAre(named name: String) -> NSFetchRequest<Goal> {
        let fetchReq = Goal.fetchRequest() as NSFetchRequest<Goal>
        fetchReq.predicate = NSPredicate(format: "title = %@", name.trimmed)
        return fetchReq
    }
}
