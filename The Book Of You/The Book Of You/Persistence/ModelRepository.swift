//
//  ModelRepository.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 5/9/23.
//

import CoreData

protocol ModelRepo {
    func fetchChapter(by url: URL) throws -> Chapter
    func fetchPage(by url: URL) throws -> Page
}

class ModelRepository: ModelRepo {
    enum Errors: Error {
    case urlTypeMismatch, urlDoesNotConvertToManagedObjectId
    }

    private let moc: NSManagedObjectContext
    private let cooridinator: NSPersistentStoreCoordinator

    /// NOTE: THE MOC SHOULD BE USED ON THE ACTOR IT WAS CREATED ON
    init(_ moc: NSManagedObjectContext, _ persistentStoreCoordinator: NSPersistentStoreCoordinator) {
        self.moc = moc
        self.cooridinator = persistentStoreCoordinator
    }

    /// Returns Page or Throws Errors type
    func fetchPage(by url: URL) throws -> Page {
        return try fetch(by: url)
    }

    func fetchChapter(by url: URL) throws -> Chapter {
        return try fetch(by: url)
    }

    private func fetch<Model: NSManagedObject>(by url: URL) throws -> Model {
        guard let managedObjectID = cooridinator.managedObjectID(forURIRepresentation: url) else {
            throw Errors.urlDoesNotConvertToManagedObjectId
        }
        if let model = moc.object(with: managedObjectID) as? Model {
            return model
        } else {
            throw Errors.urlTypeMismatch
        }
    }
}
