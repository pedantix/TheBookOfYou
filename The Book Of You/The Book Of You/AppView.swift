//
//  AppView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/6/23.
//

import SwiftUI


struct AppView: View {
    @StateObject private var navStore = NavStore()
    
    var body: some View {
        NavigationStack(path: $navStore.path) {
            
            CoverView()
                .navigationDestination(for: Destinations.self) { destination in
                    switch destination {
                    case .intro:
                        IntroView()
                    case .cover:
                        CoverView()
                    }
                }
            
        }
        .environmentObject(navStore)
        
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
