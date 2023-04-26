//
//  IndexView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/8/23.
//

import SwiftUI

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
            List {
                currentChapterSection
            }
        case 1...Int.max:
            multiChapterBody
        default:
            Text("Sad Panda negative chapters somehow")
        }
    }

    private var multiChapterBody: some View {
        List {
            currentChapterSection
            ForEach(pastChapters) { chapter in
                ChapterSection(chapter: chapter)
            }
        }
    }

    @ViewBuilder
    private var currentChapterSection: some View {
        if let firstChapter = currentChapter.first {
            ChapterSection(chapter: firstChapter)
        } else {
            ErrorView(reasons: ["First chapter not found via core data!!!"])
        }
    }

    private var newBookView: some View {
        VStack(spacing: 20) {
            Text("You must write your first Chapter").font(.title2)
            Text("Decide who you want to be tommorow, be bold!").font(.subheadline)
            NavigationLink("Create Your First Chapter", value: Destination.chapterCreator)
        }
    }
}

private struct ChapterSection: View {
    let chapter: Chapter

    var body: some View {
        lazy var cvm = IndexChapterViewModel(chapter: chapter)
        Section(header: Text(cvm.chapterHeading)) {
            NavigationLink(value: Destination.chapterCreator) {
                Text("Make a new chapter - Change Your Goals")
            }

            // TODO: If pages are empty make deletable/change goals and throw away empty chapter on save

            NavigationLink(value: Destination.pageCreator) {
                Text("Add or edit today's entry - TODO: work this out logicall")
            }

            Text("TODO: List page entries, no more then 3 if 5+ exist, with a collapse uncollapse button")
        }.listRowSeparator(.hidden)
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
