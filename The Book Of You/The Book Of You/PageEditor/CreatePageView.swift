//
//  CreatePageView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 5/9/23.
//

import SwiftUI

struct CreatePageView: View {
    @EnvironmentObject private var navStore: NavStore
    @EnvironmentObject private var appAlerter: AppAlertMessenger
    @Environment(\.dependencyGraph) var dependencyGraph
    @State private var showEscapeButton = false

    let chapterURL: URL
    private var modelRepo: ModelRepo {
        dependencyGraph.modelServiceGraph.modelRepo
    }
    private var pageCreatorService: PageCreatorService {
        dependencyGraph.modelServiceGraph.pageCreatorService
    }

    var body: some View {
        VStack {
            Text("Creating Draft Page")
                .font(.largeTitle)
                .padding()
            Image(systemName: "newspaper")
                .font(.system(size: .fs11))
                .fontWeight(.thin)
                .foregroundStyle(.foreground)
            if  showEscapeButton {
                Button("Push To Attempt To Recover", role: .destructive) {
                    navStore.popBack()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .task {
            createAPageAndNavThere()
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    func createAPageAndNavThere() {
        do {
            let chapter = try modelRepo.fetchChapter(by: chapterURL)
            let newPage = try pageCreatorService.createPage(for: chapter)
            navStore.popAndNavigate(to: .page(pageURI: newPage.objectID.uriRepresentation()))
        } catch let nsError as NSError {
            showEscapeButton = true
            appAlerter.displayNewAlert(AppAlert.persistenceAlert(nsError))
            viewLogger.contextError(nsError)
        }

    }
}

struct CreatePageView_Previews: PreviewProvider {
    static var persistenceController: PersistenceController = PersistenceController.controllerForUIPreview()

    static var chapter: Chapter = {
        persistenceController.viewContext.addChapter()
    }()

    // NOTE: Recovery button shows, this is known because of the mismatch between
    // dependency graph and preview object
    static var previews: some View {
        CreatePageView(chapterURL: chapter.objectID.uriRepresentation())
            .environmentObject(NavStore())
            .environmentObject(AppAlertMessenger())
            .environment(\.managedObjectContext, persistenceController.viewContext)
    }
}
