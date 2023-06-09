//
//  TestCoreDataStack.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 4/19/23.
//

import Foundation
import CoreData
import XCTest

// The following is a convience class for removing boilerplate
class BackgroundContextTestCase: XCTestCase {
    private(set) var context: NSManagedObjectContext!
    private(set) var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    private(set) var testStack: TestCoreDataStack!
    override func setUp() async throws {
        try await super.setUp()
        testStack = TestCoreDataStack()
        context = testStack.persistenContainer.newBackgroundContext()
        persistentStoreCoordinator = testStack.persistenContainer.persistentStoreCoordinator
    }
}

class TestCoreDataStack: NSObject {
    lazy var persistenContainer: NSPersistentContainer = {
        let description = NSPersistentStoreDescription()
        description.url = URL(filePath: "/dev/null")
        let container = NSPersistentContainer(name: "The_Book_Of_You")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, maybeErr in
            if let error = maybeErr as? NSError {
                fatalError("Error loading test core data stack \(error) \(error.userInfo)")
            }
        }
        return container
    }()
}
