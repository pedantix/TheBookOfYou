//
//  IndexView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/8/23.
//

import SwiftUI

// TODO: Extract this and make it look better for production
struct ErrorView: View {
    let reasons: [String]

    var body: some View {
        VStack {
            Text("Sorry, there has been an error dispaying your view")
            ForEach(reasons, id: \.self) {
                Text("Reason: \($0)")
            }
        }
    }
}

struct IndexView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(fetchRequest: Chapter.currentChapter())
    private var currentChapter: FetchedResults<Chapter>

    @FetchRequest(fetchRequest: Chapter.allPastChapters())
    private var pastChapters: FetchedResults<Chapter>

    @FetchRequest(fetchRequest: Chapter.allChaptersSorted())
    private var chapters: FetchedResults<Chapter>

    var body: some View {
        bodyContent
        .listStyle(.plain)
        .navigationTitle("Index")
    }

    @ViewBuilder
    private var bodyContent: some View {
        switch chapters.count {
        case .zero:
            newBookView
        case 1:
            oneChapterView
        case 1...Int.max:
            multiChapterBody
        default:
            Text("Sad Panda negative chapters somehow")
        }
    }

    private var multiChapterBody: some View {
        List {
            Section("<Current Chapter - Title> - From <start> - present" ) {

                NavigationLink(value: Destinations.chapterCreator) {
                    Text("Make a new chapter - Edit Goals  - TODO:")
                }

                Text("Make a new entry - Journal for the day, TODO: Edit or create - TODO:")
            }
            .listRowSeparator(.hidden)

           Section("<Last Chapter - title> - From start - end" ) {
                Text("summarize chapter, goals attributes - TODO: make this work")
                Text("page - x - <optional title> - date - TODO")
                Text("page - y - <optional title> - date - TODO")
                Text("page - z - <optional title> - date - TODO")
                Text("Button to expand or collpse more then 5 pages - TODO")
            }
            .listRowSeparator(.hidden)

            Section("<Chapter Before Last - title> - From start - end" ) {
                Text("summarize chapter, goals attributes - TODO: make this work")
                Text("page - x - <optional title> - date - TODO")
                Text("page - y - <optional title> - date - TODO")
                Text("page - z - <optional title> - date - TODO")
                Text("Button to expand or collpse more then 5 pages - TODO")
            }
            .listRowSeparator(.hidden)
        }
    }

    @ViewBuilder
    private var oneChapterView: some View {
        if let firstChapter = currentChapter.first {
            Section("\(firstChapter.formattedTitle) - From \(firstChapter.formattedDate) - present" ) {

                NavigationLink(value: Destinations.chapterCreator) {
                    Text("Make a new chapter - Edit Goals  - TODO:")
                }

                Text("Make a new entry - Journal for the day, TODO: Edit or create - TODO:")
            }
        } else {
            ErrorView(reasons: ["First chapter not found via core data!!!"])
        }
    }

    private var newBookView: some View {
        VStack(spacing: 20) {
            Text("You must write your first Chapter").font(.title2)
            Text("Decide who you want to be tommorow, be bold!").font(.subheadline)
            NavigationLink("Create Your First Chapter", value: Destinations.chapterCreator)
        }
    }

}

struct IndexView_Previews: PreviewProvider {
    static let preview = PersistenceController.controllerForUIPreview()

    static var previews: some View {
        NavigationStack {
            IndexView()
                .environment(\.managedObjectContext, preview.viewContext)
        }
    }
}

struct IndexViewWithOneChapter_Previews: PreviewProvider {
    static let preview: PersistenceController = {
        let controller = PersistenceController.controllerForUIPreview()
        _ = controller.addChapters(1)
        return controller
    }()

    static var previews: some View {
        NavigationStack {
            IndexView()
                .environment(\.managedObjectContext, preview.viewContext)
        }
    }
}

struct IndexViewWithTwoChapter_Previews: PreviewProvider {
    static let preview: PersistenceController = {
        let controller = PersistenceController.controllerForUIPreview()
        _ = controller.addChapters(2)
        return controller
    }()

    static var previews: some View {
        NavigationStack {
            IndexView()
                .environment(\.managedObjectContext, preview.viewContext)
        }
    }
}

struct IndexViewWithFiveChapter_Previews: PreviewProvider {
    static let preview: PersistenceController = {
        let controller = PersistenceController.controllerForUIPreview()
        _ = controller.addChapters(5)
        return controller
    }()

    static var previews: some View {
        NavigationStack {
            IndexView()
                .environment(\.managedObjectContext, preview.viewContext)
        }
    }
}
