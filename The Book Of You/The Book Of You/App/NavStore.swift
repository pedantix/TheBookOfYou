//
//  NavStore.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/6/23.
//

import SwiftUI
import CoreData

enum Destination: Codable, Hashable {
    case cover
    case intro
    case about
    case index
    case chapterCreator
    case pageCreator
    // TODO: test this usage of uri/url for managed objects with unit tests
    // https://www.cocoawithlove.com/2008/08/safely-fetching-nsmanagedobject-by-uri.html
    case chapter(objectURI: URL)
    case page(objectURI: URL)
}

// NOTE: NavPath is codable so this can be used both for incoming path requests
// as well as storage in scene store for restoration in other words the flexibility of path storgage
@MainActor final class NavStore: ObservableObject {
    @Published var path = NavigationPath()

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func encode() -> Data? {
        return try? path.codable.map(encoder.encode)
    }

    func restore(from data: Data) {
        do {
            let codable = try decoder.decode(NavigationPath.CodableRepresentation.self, from: data)
            path = NavigationPath(codable)
        } catch {
            path = NavigationPath()
        }
    }
}
