//
//  ChapterSectionView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 5/5/23.
//

import SwiftUI

// TODO: Finsih the following tasks to complete the chapter section
// - Display Pages In Order, draft at top
// - Display create IF chapter is not ended and there is not a draft
// - Link to page view
// - Show a work icon/vacation icon for vacay days

struct ChapterSectionView: View {
    let chapter: Chapter
    @State private var viewModel: IndexChapterViewModel
    @State private var isEditingChapter = false

    init(chapter: Chapter) {
        self.chapter = chapter
        self.viewModel = IndexChapterViewModel(chapter: chapter)
    }

    var body: some View {
        lazy var cvm = IndexChapterViewModel(chapter: chapter)
        Section(header: chapterChapterSectionHeader) {
            if let draftPage = chapter.draftPage {
                NavigationLink(value: Destination.pageEditor(objectURI: draftPage.objectID.uriRepresentation())) {
                    Text("Edit draft entry - TODO: make this work functionally")
                }
            } else {
                NavigationLink(value: Destination.pageCreator) {
                    Text("Create draft entry - TODO: make this work functionally")
                }
            }
            ForEach(Array(chapter.publishedPages.enumerated()), id: \.element) { offset, page in
                NavigationLink(value: Destination.page(objectURI: page.objectID.uriRepresentation())) {
                    HStack {
                        Text("TODO: make this nicey nicey \(page.entryDate?.description ?? "no date")")
                        Spacer()
                        Text("\(offset)")
                    }
                }
            }
        }.listRowSeparator(.hidden)
    }

    private var chapterChapterSectionHeader: some View {
        VStack(alignment: .leading) {
            Text(viewModel.title)
                .font(.title3)
            HStack {
                Text(viewModel.dateBlock)
                    .font(.callout)
                Spacer()
                Button {
                    isEditingChapter = true
                } label: {
                    Label("Edit", systemImage: "square.and.pencil")
                }
            }
        }
        .sheet(isPresented: $isEditingChapter) {
            // TODO: the following
            Text("TODO: Create Chapter Editor and replace here")
        }
    }
}

struct ChapterSectionView_Previews: PreviewProvider {
    static let controller = PersistenceController.controllerForUIPreview()

    static let chapters: [Chapter] = {
        let chapFromPast = controller.viewContext.addChapters().first!
        let chapFromPresent = controller.viewContext.addChapters().last!
        controller.viewContext.addPages(to: chapFromPast, includeDraft: true)
        return [chapFromPast, chapFromPresent]
    }()

    static var previews: some View {
        Group {
            ForEach(chapters) { chap in
                List {
                    ChapterSectionView(chapter: chap)
                }
                .listStyle(.plain)
            }
        }
    }
}
