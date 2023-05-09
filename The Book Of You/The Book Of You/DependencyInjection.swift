//
//  DependencyInjection.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 5/3/23.
//

import SwiftUI

protocol DependencyGraph: ObservableObject {
    var validatorGraph: ValidatorGraph { get }
    var modelServiceGraph: ModelServiceGraph { get }
}

protocol ModelServiceGraph {
    var pageCreatorService: PageCreatorService { get }
}

protocol ValidatorGraph {
    var pageValidator: PageValidator { get }
    var pageEntriesValidator: PageEntriesValidator { get }
    var textEntryValidator: TextEntryValidator { get }
    var chapterValidator: ChapterValidator { get }
}

// MARK: - Prod graph

private class ProdDependencyGraph: DependencyGraph {
    var validatorGraph: ValidatorGraph = ProdValidatorGraph()
    var modelServiceGraph: ModelServiceGraph = ProdModelServiceGraph()
}

private class ProdModelServiceGraph: ModelServiceGraph {
    var pageCreatorService: PageCreatorService = PageCreatorService(
        viewContext: PersistenceController.shared.viewContext
    )
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
