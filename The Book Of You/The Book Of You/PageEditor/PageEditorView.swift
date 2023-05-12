//
//  PageCreatorView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/30/23.
//

import SwiftUI
import CoreData

struct PageEditorView: View {
    enum Load {
        case loading, failed, loaded(Page)
    }
    @EnvironmentObject private var appMessenger: AppAlertMessenger
    @Environment(\.dependencyGraph) private var graph
    @Environment(\.managedObjectContext) private var moc
    @State private var load: Load = .loading
    let pageURI: URL

    var body: some View {
        VStack {
            switch load {
            case .failed:
                Text("Failed to load page from context")
            case .loading:
                Text("Loading page from context")
            case .loaded(let page):
                _PageEditorView(page, .init(page, graph.validatorGraph))
            }
        }
        .task {
            loadPage()
        }
    }

    @MainActor private func loadPage() {
        do {
            let page = try graph.modelServiceGraph.modelRepo.fetchPage(by: pageURI)
            load = .loaded(page)
        } catch let err as NSError {
            appMessenger.displayNewAlert(.persistenceAlert(err))
            viewLogger.contextError(err, "loading page from URL for navigation")
        }
    }
}

private struct _PageEditorView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject private var viewModel: PageEditorViewModel
    @ObservedObject private var page: Page

    init(_ page: Page, _ viewModel: PageEditorViewModel) {
        self.viewModel = viewModel
        self.page = page
    }

    var body: some View {
        List {
            DateEntryView(page, moc)
            // TODO: Vacation Toggle
            Text("TODO: Vacation Toggle")
            ForEach(viewModel.entries) { entry in
                PageEntryView(entry: entry)
            }
        }
        .listStyle(.plain)
    }
}

private struct PageEntryView: View {
    @Environment(\.managedObjectContext) private var moc
    let entry: PageEditorViewModel.Entry

    var body: some View {
        switch entry {
        case .text(let goal, let textEntry, let errors):
            let goalViewModel = GoalTextEditorViewModel(goal, textEntry, errors, moc)
            // TODO: nice up this
            TextEditorView(goal.title ?? "NO TITLE, contact developer", goalViewModel)
        case .freeText(let page, let errors):
            let viewModel = PageFreeTextEditorViewModel(page, errors, moc)
            TextEditorView("Journal Entry", viewModel)
        }
    }
}

struct PageEditorView_Previews: PreviewProvider {
    private static let controller = PersistenceController.controllerForUIPreview()

    private static var pagesForPreview: [(String, Page)] = {
        let vacayPage = controller.viewContext.addVacationPage()
        let goalPage = controller.viewContext.addPage(goals: 2)
        let goalPageInVacayMode = controller.viewContext.addPage(goals: 2, isVacation: true)

        return [
            ("Vacation Chapter Page", vacayPage),
            ("Goal Chapter Page", goalPage),
            ("Goal Chapter Page in Vacation Mode", goalPageInVacayMode)
        ]
    }()

    static var previews: some View {

        Group {
            ForEach(pagesForPreview, id: \.0) { (pageDescription, page) in
                NavigationStack {
                    PageEditorView(pageURI: page.objectID.uriRepresentation())
                }
                .previewDisplayName(pageDescription)
            }
            .environment(\.dependencyGraph, PreviewDependencyGraph(controller))
            .environment(\.managedObjectContext, controller.viewContext)
            .environmentObject(AppAlertMessenger())
        }
    }
}
