//
//  CoverView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/6/23.
//

import SwiftUI

struct CoverView: View {
    @EnvironmentObject private var navStore: NavStore

    // NOTES: Questions, can I easily build an evenly spaced VStack?
    var body: some View {
        ZStack {
            ClickableBackgroundView {
                navStore.path.append(Destination.intro)
                viewLogger.info("Turn Cover Page To Next")
            }
            VStack {
                Spacer()
                Text("The Book of You")
                    .font(.title)
                Text("A journal to support goals habbits and dreams")
                    .font(.subheadline)
                Spacer()
                Text("Author: You")
                    .font(.subheadline)
                Spacer()
            }
        }
    }
}

struct CoverView_Previews: PreviewProvider {
    static var previews: some View {
        CoverView()
    }
}
