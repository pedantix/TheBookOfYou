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
            AppTestHelper().resetIfIsUITest()

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
                        CreatePageView(chapterURL: uri)
                    case let.page(pageURI: uri):
                        PageEditorView(pageURI: uri)
                    }
                }
        }
        .onAppear {
            UITextField.appearance().clearButtonMode = .whileEditing
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
