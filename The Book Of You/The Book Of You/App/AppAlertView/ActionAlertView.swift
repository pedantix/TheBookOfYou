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
    @EnvironmentObject private var messenger: AppAlertMessenger
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

struct AppAlertable: ViewModifier {
    @EnvironmentObject private var appAlerter: AppAlertMessenger
    private let alertPublisher: Published<AppAlert?>.Publisher

    init(_ publisher: Published<AppAlert?>.Publisher) {
        alertPublisher = publisher
    }

    func body(content: Content) -> some View {
        content
            .onReceive(alertPublisher) { maybeAlert in
                guard let alert = maybeAlert else { return }
                appAlerter.displayNewAlert(alert)
            }
    }
}

// MARK: - Examppe usage
private class TestViewModel: ObservableObject {
    @Published var appAlert: AppAlert?

    func showAlert() {
        appAlert = AppAlert(
            title: "Not Added",
            message: "The list was already full, please remove an object from the list form in order to add",
            sfSymbolText: "square.3.layers.3d.down.right.slash")
    }
}

private struct TestView: View {
    @EnvironmentObject var alertMessenger: AppAlertMessenger
    @ObservedObject private var viewModel = TestViewModel()

    var body: some View {
        ZStack {
            Button("Show") {
                viewModel.showAlert()
            }
            .modifier(AppAlertable(viewModel.$appAlert))
        }
    }
}

struct ActionAlertView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            TestView()
            AppAlertView()
        }
        .environmentObject(AppAlertMessenger())
    }
}
