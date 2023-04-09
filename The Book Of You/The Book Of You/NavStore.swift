//
//  NavStore.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/6/23.
//

import SwiftUI

enum Destinations: String, Codable {
    case cover
    case intro
    case about
    case index
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
