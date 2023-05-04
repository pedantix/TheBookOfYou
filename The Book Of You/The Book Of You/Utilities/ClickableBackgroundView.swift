//
//  ClickableBackgroundView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/8/23.
//

import SwiftUI

struct ClickableBackgroundView: View {
    // NOTE: Added this here to force testability, may need to evolve over time

    typealias Action = () -> Void
    private let accessibilityText: String
    private let action: Action?

    init(_ accessibilityText: String, action: Action? = nil) {
        self.accessibilityText = accessibilityText
        self.action = action
    }

    var body: some View {
        if action == nil {
            actionableBackground
        } else {
            actionableBackground
                .onTapGesture {
                    action?()
                }
        }
    }

    var actionableBackground: some View {
        GeometryReader { geometry in
            Rectangle()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .opacity(0.001)
                .layoutPriority(-1)
                .accessibilityAddTraits(.isButton)
                .accessibilityLabel(Text(accessibilityText))
        }
    }
}

private struct TestView: View {
    @State private var counter = 0

    var body: some View {
        ZStack {
            ClickableBackgroundView("Click Me!") {
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
