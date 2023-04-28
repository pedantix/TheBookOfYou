//
//  ActionAlertView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/28/23.
//

import SwiftUI

private extension TimeInterval {
    static let easeInTime: TimeInterval = 0.5
    static let easeOutTime: TimeInterval = 0.5
    static let displayTime: TimeInterval = 2
}

class ActionAlertMessenger: ObservableObject {
    @Published fileprivate var alertData: ActionAlertData?
    @Published fileprivate var visible = false {
        didSet {
            if !visible {
                hideTask?.cancel()
                hideTask = Task {
                    try await Task.sleep(for: .seconds(.easeOutTime))
                    alertData = nil
                }
            }
        }
    }
    private var hideTask: Task<Void, Error>?

    func displayNewAlert(_ data: ActionAlertData) {
        hideTask?.cancel()
        alertData = data
        visible = true

        hideTask = Task {
            try await Task.sleep(for: .seconds(.displayTime))
            visible = false
        }
    }
}

struct ActionAlertView: View {
    @EnvironmentObject var messenger: ActionAlertMessenger
    @State private var data: ActionAlertData?
    @State private var visiblity: CGFloat = 0

    var body: some View {
        display
            .opacity(visiblity)
            .onReceive(messenger.$visible) { visible in
                if visible {
                    withAnimation(.easeIn(duration: .easeInTime)) {
                        visiblity = 1.0
                    }
                } else {
                    withAnimation(.easeOut(duration: .easeOutTime)) {
                        visiblity = 0.0
                    }
                }
            }
    }

    @ViewBuilder
    private var display: some View {
        if let data = messenger.alertData {
            ActionAlertDisplayView(data: data)
                .onTapGesture {
                    messenger.visible = false
                }
        } else {
            EmptyView()
        }
    }
}

struct ActionAlertView_Previews: PreviewProvider {
    static var previews: some View {
        let data = ActionAlertData(
            title: "Not Added",
            message: "The list was already full, please remove an object from the list form in order to add",
            sfSymbolText: "square.3.layers.3d.down.right.slash")
        let messenger = ActionAlertMessenger()
        ZStack {
            Button("Show") {
                messenger.displayNewAlert(data)
            }
            ActionAlertView()
        }
        .environmentObject(messenger)
    }
}
