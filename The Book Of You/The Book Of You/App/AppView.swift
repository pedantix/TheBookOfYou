//
//  AppView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/6/23.
//

import SwiftUI

struct AppView: View {
    @StateObject private var alertMessenger = AppAlertMessenger()
    @StateObject private var navStore = NavStore()
    @SceneStorage(.navigationKey) private var navStoreData: Data?

    var body: some View {
        ZStack {
            appView
            AppAlertView()
        }
        .environmentObject(alertMessenger)
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

    // TODO: Implement all app views
    private var appView: some View {
        NavigationStack(path: $navStore.path) {
            CoverView()
                .navigationDestination(for: Destination.self) { destination in
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
                        ChapterCreatorView()
                    case let.pageCreator(chapterURI: uri):
                        Text("TODO: Create page for chapter of URI\(uri)")
                    case let.page(objectURI: uri):
                        Text("TODO: display \(uri) for PAGE")
                    }
                }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
