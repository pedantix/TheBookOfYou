//
//  DependencyInjection.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 5/3/23.
//

import SwiftUI
import CoreData

protocol DependencyGraph: ObservableObject {
    var validatorGraph: ValidatorGraph { get }
    var modelServiceGraph: ViewModelServiceGraph { get }
}

// MARK: - Model Graph
@MainActor
protocol ViewModelServiceGraph: ModelServiceGraph { }

// NOTE this should be used in an actor bound way for background model interaction usage
protocol ModelServiceGraph {
    var pageCreatorService: PageCreatorService { get }
    var modelRepo: ModelRepo { get }
}

private class ProdModelServiceGraph: ViewModelServiceGraph {
    let context: NSManagedObjectContext
    private let coordinator: NSPersistentStoreCoordinator

    init(_ context: NSManagedObjectContext, _ coordinator: NSPersistentStoreCoordinator) {
        self.context = context
        self.coordinator = coordinator
    }

    lazy var pageCreatorService: PageCreatorService = PageCreatorService(
        viewContext: context
    )

    lazy var modelRepo: ModelRepo = ModelRepository(context, coordinator)
}

// MARK: - Validator Graph
protocol ValidatorGraph {
    var pageValidator: PageValidator { get }
    var pageEntriesValidator: PageEntriesValidator { get }
    var textEntryValidator: TextEntryValidator { get }
    var chapterValidator: ChapterValidator { get }
}

// MARK: - Prod graph

private class ProdDependencyGraph: DependencyGraph {
    var validatorGraph: ValidatorGraph = ProdValidatorGraph()
    @MainActor var modelServiceGraph: ViewModelServiceGraph = {
            let persistentStore = PersistenceController.shared
            return  ProdModelServiceGraph(persistentStore.viewContext, persistentStore.persistentStoreCoordinator)
    }()
}

private class ProdValidatorGraph: ValidatorGraph {
    var textEntryValidator: TextEntryValidator = TextEntryValidator()
    var chapterValidator: ChapterValidator = ChapterValidator()
    lazy var pageEntriesValidator: PageEntriesValidator = PageEntriesValidator(textEntryValidator)
    lazy var pageValidator: PageValidator = PageValidator(pageEntriesValidator)
}

// MARK: - Singleton
extension The_Book_Of_YouApp {
    static let prodGraph: any DependencyGraph = ProdDependencyGraph()
}

// MARK: - Add to SwiftUI Environment
private struct DependencyInjectionKey: EnvironmentKey {
    static let defaultValue: any DependencyGraph = The_Book_Of_YouApp.prodGraph
}

extension EnvironmentValues {
    var dependencyGraph: any DependencyGraph {
        get { self[DependencyInjectionKey.self] }
        set { self[DependencyInjectionKey.self] = newValue}
    }
}
