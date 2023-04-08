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
            GeometryReader { geometry in
                
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(0.001)   // <--- important
                    .layoutPriority(-1)
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
            
        }.onTapGesture {
            navStore.path.append(Destinations.intro)
            viewLogger.info("Turn Cover Page To Next")
        }
    }
}

struct CoverView_Previews: PreviewProvider {
    static var previews: some View {
        CoverView()
    }
}
