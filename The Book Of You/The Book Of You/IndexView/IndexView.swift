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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink("New", value: Destination.chapterCreator)
            }
        }
    }

    @ViewBuilder
    private var bodyContent: some View {
        if chapters.count > 0 {
            List {
                ForEach(chapters) { chapter in
                    ChapterSectionView(chapter: chapter)
                }
            }
        } else {
            newBookView
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
        _ = controller.viewContext.addChapters(1)
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
        _ = controller.viewContext.addChapters(2)
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
        _ = controller.viewContext.addChapters(5)
        return controller
    }()

    static var previews: some View {
        NavigationStack {
            IndexView()
                .environment(\.managedObjectContext, preview.viewContext)
        }
    }
}
