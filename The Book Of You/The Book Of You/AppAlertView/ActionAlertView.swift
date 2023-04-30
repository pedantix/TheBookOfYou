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

protocol AlertMessenger {
    func displayNewAlert(_ data: AppAlert)
}

class AppAlertMessenger: ObservableObject, AlertMessenger {
    @Published fileprivate var alertData: AppAlert?
    @Published fileprivate var visible = false {
        didSet {
            if !visible {
                hideTask?.cancel()
                hideTask = Task {
                    try await Task.sleep(for: .seconds(.easeOutTime))
                    await MainActor.run {
                        alertData = nil
                    }
                }
            }
        }
    }
    private var hideTask: Task<Void, Error>?

    func displayNewAlert(_ data: AppAlert) {
        hideTask?.cancel()
        alertData = data
        visible = true

        hideTask = Task {
            try await Task.sleep(for: .seconds(.displayTime))
            await MainActor.run {
                visible = false
            }
        }
    }
}

struct AppAlertView: View {
    @EnvironmentObject var messenger: AppAlertMessenger
    @State private var data: AppAlert?
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
            AppAlertDisplayView(data: data)
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
        let data = AppAlert(
            title: "Not Added",
            message: "The list was already full, please remove an object from the list form in order to add",
            sfSymbolText: "square.3.layers.3d.down.right.slash")
        let messenger = AppAlertMessenger()
        ZStack {
            Button("Show") {
                messenger.displayNewAlert(data)
            }
            AppAlertView()
        }
        .environmentObject(messenger)
    }
}
