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
}

// NOTE: NavPath is codable so this can be used both for incoming path requests as well as storage in scene store for restoration
// in other words the flexibility of path storgage

@MainActor final class NavStore: NSObject, ObservableObject {
    @Published var path = NavigationPath()
    
}
