//
//  DependencyInjection.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 5/3/23.
//

import Foundation

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
}

extension The_Book_Of_YouApp {
    static let prodGraph: any DependencyGraph = ProdDependencyGraph()
}

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
    lazy var pageEntriesValidator: PageEntriesValidator = PageEntriesValidator(textEntryValidator)
    lazy var pageValidator: PageValidator = PageValidator(pageEntriesValidator)
}
