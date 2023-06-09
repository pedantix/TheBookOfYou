//
//  ChapterSectionView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 5/5/23.
//

import SwiftUI

struct ChapterSectionView: View {
    @FetchRequest private var draftPage: FetchedResults<Page>
    @FetchRequest private var publishedPages: FetchedResults<Page>
    @ObservedObject private(set) var chapter: Chapter
    @ObservedObject private var viewModel: IndexChapterViewModel
    @State private var isEditingChapter = false
    @Environment(\.managedObjectContext) private var viewContext

    init(chapter: Chapter) {
        self._draftPage = FetchRequest(fetchRequest: Page.draftPages(for: chapter))
        self._publishedPages = FetchRequest(fetchRequest: Page.publishedPages(for: chapter))
        viewModel = IndexChapterViewModel(chapter: chapter)
        self.chapter = chapter
    }

    var body: some View {
        Section(header: chapterChapterSectionHeader) {
            if draftPage.count > 0 {
                ForEach(draftPage) { draftPage in
                    let pageViewModel = PageRowViewModel(page: draftPage)
                    NavigationLink(value: Destination.page(pageURI: pageViewModel.pageUrl)) {
                        Text("Edit draft from \(pageViewModel.entryDate)")
                    }
                }
            } else if !viewModel.chapterIsEnded {
                NavigationLink(value: Destination.pageCreator(chapterURI: chapter.objectID.uriRepresentation())) {
                    Text("Create a New Page!")
                }
            }

            ForEach(publishedPages) { page in
                let pageVM = PageRowViewModel(page: page)
                NavigationLink(value: Destination.page(pageURI: pageVM.pageUrl)) {
                    HStack {
                        if pageVM.isVacation {
                            Image(systemName: "laurel.leading")
                        }
                        Text(pageVM.entryDate)
                        if pageVM.isVacation {
                            Image(systemName: "laurel.trailing")
                        }
                        Spacer()
                        Text("\((publishedPages.firstIndex(of: page) ?? 0) + 1)")
                            .underline()
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
            NavigationStack {
                ChapterEditorView(chapter, $isEditingChapter, moc: viewContext)
            }
        }
    }
}

#if DEBUG
struct ChapterSectionView_Previews: PreviewProvider {
    static let controller = PersistenceController.controllerForUIPreview()

    static let chapters: [Chapter] = {
        let chapFromPast = controller.viewContext.addChapters().first!
        let chapFromPresent = controller.viewContext.addChapters().last!
        controller.viewContext.addPages(to: chapFromPast, includeDraft: true)
        controller.viewContext.addPage(to: chapFromPast, daysAgo: 7, isVacation: true)
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
        .environmentObject(AppAlertMessenger())
        .environment(\.managedObjectContext, controller.viewContext)
    }
}
#endif
