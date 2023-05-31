//
//  Persistence.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 3/29/23.
//

import CoreData
import CloudKit

struct PersistenceController {
    static let shared: PersistenceController = {
        switch LaunchScenario.current {
        case .application:
            return PersistenceController()
        case .blankSlate:
            return PersistenceController(inMemory: true)
        case .sixGoals:
            let controller = PersistenceController(inMemory: true)
            for _ in 0..<6 {
                controller.viewContext.addGoal()
            }
            return controller
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

        if !inMemory {
            #if DEBUG
            checkAccountStatus()
            persistenceLogger.info("Setting up DEV cloud kit schema")
            do {
                try container.initializeCloudKitSchema()
            } catch let err as NSError {
                persistenceLogger.error("Error setting up cloud kit container \(err) ")
            }
            persistenceLogger.info("Setup DEV cloud kit schema, remember to promote before rolling to prod")
            #endif
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    /// This check is being done to see if the CK account is available so data may or may not be sunk
    private func checkAccountStatus() {
        CKContainer.default().accountStatus { status, error in
            switch status {
            case .available:
                persistenceLogger.info("CK Container account available!")
            default:
                persistenceLogger.info("CK Container not available! \(status)")
            }
            if let error = error {
                print(error)
            }
        }
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

    var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        return self.container.persistentStoreCoordinator
    }
}
#if DEBUG
extension NSManagedObjectContext {
    @discardableResult
    func addChapter(daysAgo: Int = 5, goals: Int = 0) -> Chapter {
        let newItem = Chapter(context: self)
        newItem.title = "A chapter from \(daysAgo) days ago"
        newItem.dateStarted = .date(daysAgo: daysAgo)
        if daysAgo != 1 {
            newItem.dateEnded = .date(daysAgo: daysAgo)
        }
        saveContext()

        for idx in 0..<goals {
            addGoal("Chapter Goal \(idx)", with: newItem)
        }

        return newItem
    }

    @discardableResult
    func addChapters(_ count: Int = 5) -> [Chapter] {
        var chapters = [Chapter]()
        for item in (1...count).reversed() {
            chapters.append(addChapter(daysAgo: item))
        }
        return chapters
    }

    @discardableResult
    func addVacationChapter(daysAgo: Int = 5) -> Chapter {
        let newItem = Chapter(context: self)
        newItem.title = "A Vacation chapter from \(daysAgo) days ago"
        newItem.dateStarted = .date(daysAgo: daysAgo)
        newItem.isVacation = true
        if daysAgo != 1 {
            newItem.dateEnded = .date(daysAgo: daysAgo)
        }
        saveContext()
        return newItem
    }

    @discardableResult
    func addGoal(_ title: String = "A Worthy Goal", with chapter: Chapter? = nil) -> Goal {
        let viewContext = self
        let goal = Goal(context: viewContext)
        goal.title = title
        if let chapter = chapter {
            let chapGoal = ChapterGoal(context: viewContext)
            let idxOrder: Int64
            if chapter.chapterGoals?.count == 0 {
                idxOrder = 0
            } else {
                let maxIdx = chapter.chapterGoals?
                    .compactMap { $0 as? ChapterGoal }
                    .compactMap { $0.orderIdx }.max() ?? 0
                idxOrder = maxIdx + 1
            }

            chapGoal.chapter = chapter
            chapGoal.goal = goal
            chapGoal.orderIdx = idxOrder
        }

        saveContext()
        return goal
    }

    @discardableResult
    func addVacationPage(chapter: Chapter? = nil) -> Page {
        let vacationChapter = chapter ?? addVacationChapter()
        let creator = PageCreatorService(viewContext: self)
        do {
            return try creator.createPage(for: vacationChapter)
        } catch let err as NSError {
            fatalError("Unresolved error \(err), \(err.userInfo)")
        }
    }

    @discardableResult
    func addPage(goals: Int = 1, isDraft: Bool = true, daysAgo: Int = 0, isVacation: Bool = false) -> Page {
        let chapter = addChapter(goals: goals)
        return addPage(to: chapter, isDraft: isDraft, daysAgo: daysAgo, isVacation: isVacation)
    }

    @discardableResult
    func addPage(to chapter: Chapter, isDraft: Bool = false, daysAgo: Int = 0, isVacation: Bool = false) -> Page {
        let creator = PageCreatorService(viewContext: self)
        do {
            let page = try creator.createPage(for: chapter)
            page.isDraft = isDraft
            page.vacationDay = isVacation
            page.entryDate = .date(daysAgo: daysAgo)
            try save()
            return page
        } catch let err as NSError {
            fatalError("Unresolved error \(err), \(err.userInfo)")
        }
    }

    @discardableResult
    func addPages(to chapter: Chapter, count: Int = 5, includeDraft: Bool = false) -> [Page] {
        var pages = [Page]()
        for idx in 0..<count {
            let isDraft = includeDraft && idx == 0
            pages.append(addPage(to: chapter, isDraft: isDraft, daysAgo: idx))
        }

        return pages
    }

    private func saveContext() {
        do {
            try save()
        } catch let err as NSError {
            fatalError("Unresolved error \(err), \(err.userInfo)")
        }
    }
}
#endif
extension Date {
    static func date(daysAgo: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: -(daysAgo), to: .now)!
    }
}
