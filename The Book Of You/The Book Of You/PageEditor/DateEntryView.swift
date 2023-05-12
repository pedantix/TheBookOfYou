//
//  DateEntryView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 5/10/23.
//

import SwiftUI
import CoreData

class DateEntryViewViewModel: ObservableObject {
    @Published var editorDate: Date
    @Published var alertData: AppAlert?

    private let moc: NSManagedObjectContext
    private let page: Page

    init(_ page: Page, _ moc: NSManagedObjectContext) {
        self.page = page
        self.editorDate = page.entryDate ?? .now
        self.moc = moc
    }

    func saveDate() {
        do {
            self.page.entryDate = editorDate
            try moc.save()
        } catch let error as NSError {
            viewModelLogger.contextError(error)
            alertData = .persistenceAlert(error)
            moc.rollback()
        }
    }
}

struct DateEntryView: View {
    @ObservedObject private var viewModel: DateEntryViewViewModel
    @ObservedObject private var page: Page
    @State private var dateId = 1

    init(_ page: Page, _ moc: NSManagedObjectContext) {
        self.page = page
        self.viewModel = .init(page, moc)
    }

    var body: some View {
        DatePicker(selection: $viewModel.editorDate, in: ...Date.now, displayedComponents: .date) {
            Text("Entry Date")
        }

        .datePickerStyle(.compact)
        .id(dateId)
        .onChange(of: viewModel.editorDate) { _ in
            dateId += 1
        }
        .onTapGesture {
            dateId += 1
        }
        .onChange(of: viewModel.editorDate) { _ in
            viewModel.saveDate()
        }
    }
}

struct DateEntryView_Previews: PreviewProvider {
    static let controller: PersistenceController = .controllerForUIPreview()
    static let page: Page = { controller.viewContext.addPage() }()
    static var previews: some View {
        NavigationStack {
            List {
                DateEntryView(page, controller.viewContext)
            }
            .listStyle(.plain)
            .environment(\.managedObjectContext, controller.viewContext)
            .environmentObject(AppAlertMessenger())
        }
    }
}
