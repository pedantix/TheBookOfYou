//
//  Persistence.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 3/29/23.
//

import CoreData

struct PersistenceController {
    static let shared: PersistenceController = {
        switch LaunchScenario.current {
        case .application:
            return PersistenceController()
        case .blankSlate:
            return PersistenceController(inMemory: true)
        }
    }()
    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "The_Book_Of_You")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        // swiftlint:disable unused_closure_parameter
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        // swiftlint:enable unused_closure_parameter
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application,
                // although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible,
                 * due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

extension PersistenceController {
    static var preview: PersistenceController = PersistenceController(inMemory: true)

    static func controllerForUIPreview() -> PersistenceController {
        return PersistenceController(inMemory: true)
    }

    var viewContext: NSManagedObjectContext {
        return self.container.viewContext
    }
}
#if DEBUG
extension NSManagedObjectContext {
    @discardableResult
    func makeChapter(daysAgo: Int = 5) -> Chapter {
        let newItem = Chapter(context: self)
        newItem.title = "A chapter from \(daysAgo) days ago"
        newItem.dateStarted = .date(daysAgo: daysAgo)
        if daysAgo != 1 {
            newItem.dateEnded = .date(daysAgo: daysAgo)
        }

        do {
            try self.save()
        } catch let err as NSError {
            fatalError("Unresolved error \(err), \(err.userInfo)")
        }
        return newItem
    }

    @discardableResult
    func addChapters(_ count: Int = 5) -> [Chapter] {
        var chapters = [Chapter]()
        for item in (1...count).reversed() {
            chapters.append(makeChapter(daysAgo: item))
        }
        return chapters
    }

    @discardableResult
    func addGoal(_ title: String = "A Worthy Goal", with chapter: Chapter? = nil) -> Goal {
        let viewContext = self
        let goal = Goal(context: viewContext)
        goal.title = title
        if let chapter = chapter {
            let chapGoal = ChapterGoal(context: viewContext)
            chapGoal.chapter = chapter
            chapGoal.goal = goal
        }

        do {
            try viewContext.save()
        } catch let err as NSError {
            fatalError("Unresolved error \(err), \(err.userInfo)")
        }
        return goal
    }
}
#endif
extension Date {
    static func date(daysAgo: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -(daysAgo), to: .now)!
    }
}
