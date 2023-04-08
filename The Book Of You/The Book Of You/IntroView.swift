//
//  IntroView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/6/23.
//

import SwiftUI

struct IntroView: View {
    @EnvironmentObject var navStore: NavStore

    var body: some View {
        ZStack {
            ClickableBackgroundView {
                viewLogger.info("Navigate To About")
                navStore.path.append(Destinations.about)
            }
            Text("Intro")
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
