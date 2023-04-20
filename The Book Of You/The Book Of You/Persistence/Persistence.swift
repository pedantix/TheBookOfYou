//
//  Persistence.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 3/29/23.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
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

    func addChapters(_ count: Int = 5) -> [Chapter] {
        let viewContext = self.container.viewContext

        var chapters = [Chapter]()
        for item in (1...count).reversed() {
            let newItem = Chapter(context: viewContext)
            newItem.title = "Title \(count)"
            newItem.dateStarted = .date(daysAgo: count - item)
            chapters.append(newItem)
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may
            // be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return chapters
    }
}

extension Date {
    static func date(daysAgo: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: .now)!
    }
}
