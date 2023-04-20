//
//  AppView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/6/23.
//

import SwiftUI

struct AppView: View {
    @StateObject private var navStore = NavStore()
    @SceneStorage("navigation") private var navStoreData: Data?

    var body: some View {
        NavigationStack(path: $navStore.path) {
            CoverView()
                .navigationDestination(for: Destinations.self) { destination in
                    switch destination {
                    case .intro:
                        IntroView()
                    case .cover:
                        CoverView()
                    case .about:
                        AboutView()
                    case .index:
                        IndexView()
                    case .chapterCreator:
                        Text("Todo create a chapter creator")
                    }
                }
        }

        .environmentObject(navStore)
        .task {
            // Restore Nav Stack from Last State
            if let navStoreData {
                navStore.restore(from: navStoreData)
            }
            // Save Nav Stack to scene storage as it changes
            for await _ in navStore.$path.values {
                navStoreData = navStore.encode()
            }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
