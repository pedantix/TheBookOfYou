//
//  ClickableBackgroundView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/8/23.
//

import SwiftUI

struct TapableBackgroundView: View {
    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .opacity(0.001)
                .layoutPriority(-1)
        }
    }
}

struct ClickableBackgroundView: View {
    let action: () -> Void

    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .opacity(0.001)
                .layoutPriority(-1)
                .onTapGesture {
                    action()
                }
        }
    }
}

private struct TestView: View {
    @State private var counter = 0

    var body: some View {
        ZStack {
            ClickableBackgroundView {
                viewLogger.info("Clicked!")
                counter += 1
            }
            Text("Clicked \(counter)!")
        }
    }
}

struct ClickableBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
