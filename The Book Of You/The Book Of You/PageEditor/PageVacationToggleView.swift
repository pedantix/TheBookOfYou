//
//  PageVacationToggleView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 5/13/23.
//

import SwiftUI
import CoreData

class PageVacationToggleViewModel: ObservableObject {
    @Published var isVacationDay: Bool
    @Published var alertData: AppAlert?

    private let moc: NSManagedObjectContext
    private let page: Page

    init(_ page: Page, _ moc: NSManagedObjectContext) {
        self.page = page
        self.isVacationDay = page.vacationDay
        self.moc = moc
    }

    func saveDate() {
        do {
            self.page.vacationDay = isVacationDay
            try moc.save()
        } catch let error as NSError {
            viewModelLogger.contextError(error)
            alertData = .persistenceAlert(error)
            moc.rollback()
        }
    }
}

struct PageVacationToggleView: View {
    @ObservedObject private var viewModel: PageVacationToggleViewModel
    @ObservedObject private var page: Page
    @State private var dateId = 1

    init(_ page: Page, _ moc: NSManagedObjectContext) {
        self.page = page
        self.viewModel = .init(page, moc)
    }

    var body: some View {
        Toggle(isOn: $viewModel.isVacationDay) {
            Text("Vacation Day")
        }
        .onChange(of: viewModel.isVacationDay) { _ in
            viewModel.saveDate()
        }
        .listRowSeparator(.hidden)
    }
}

#if DEBUG
struct PageVacationToggleView_Previews: PreviewProvider {
    static let controller: PersistenceController = .controllerForUIPreview()
    static let page: Page = { controller.viewContext.addPage() }()
    static var previews: some View {
        NavigationStack {
            List {
                PageVacationToggleView(page, controller.viewContext)
            }
            .listStyle(.plain)
            .environment(\.managedObjectContext, controller.viewContext)
            .environmentObject(AppAlertMessenger())
        }
    }
}
#endif
