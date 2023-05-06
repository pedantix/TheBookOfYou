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
            NavigationLink(value: Destination.chapterCreator) {
                Text("Make a new chapter - Change Your Goals")
            }
            NavigationLink(value: Destination.pageCreator) {
                Text("Add or edit today's entry - TODO: work this out logicall")
            }
            Text("TODO: List page entries, no more then 3 if 5+ exist, with a collapse uncollapse button")
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

    static var previews: some View {
        let chapFromPast = controller.viewContext.addChapters().first!
        let chapFromPresent = controller.viewContext.addChapters().last!
        Group {
            ForEach([chapFromPast, chapFromPresent]) { chap in
                List {
                    ChapterSectionView(chapter: chap)
                }
                .listStyle(.plain)
            }
        }
    }
}
