//
//  ChapterEditorView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 5/9/23.
//

import SwiftUI
import CoreData

struct ChapterEditorView: View {
    @Binding private var isDisplayed: Bool
    @ObservedObject private var viewModel: ChapterEditorViewModel
    @FocusState private var isFocused: Bool
    init(_ chapter: Chapter, _ isDisplayed: Binding<Bool>, moc: NSManagedObjectContext) {
        viewModel = .init(chapter, moc: moc)
        self._isDisplayed = isDisplayed
    }

    var body: some View {
        VStack {
            TextField(
                "Chapter Title",
                text: $viewModel.editorTitle,
                prompt: Text( "Describe your focus")
            )
            .focused($isFocused)
            .submitLabel(.done)
            .onSubmit {
                viewModel.saveChapter()
            }
            .padding()
            if !viewModel.isVacation {
                List(viewModel.goals) {
                    GoalSearchRow(goal: $0)
                }
                .listStyle(.plain)
            } else {
                Spacer()
                Text("Enjoy your Vacation!\nWork hard!\nPlay hard!")
                    .font(.largeTitle)
                    .padding()
                    .multilineTextAlignment(.center)
                Spacer()
            }
        }
        .onReceive(viewModel.$didSave) { didSave in
            if didSave {
                isDisplayed = false
            }
        }
        .onAppear {
            isFocused = true
        }
        .onDisappear {
            isFocused = false
        }
        .navigationTitle("Edit Chapter")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    isDisplayed = false
                } label: {
                    Text("Cancel")
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.saveChapter()
                } label: {
                    Text("Save")
                }
            }
        }
    }
}

#if DEBUG
struct ChapterEditorView_Previews: PreviewProvider {
    static let controller = PersistenceController.controllerForUIPreview()

    static var chapters: [(String, Chapter)] = {
        let chapVaca = controller.viewContext.addVacationChapter(daysAgo: 2)
        let chapGoals = controller.viewContext.addChapter(goals: 5)

        return [("Vacation Chapter", chapVaca), ("Goals Chapter", chapGoals)]
    }()

    static var previews: some View {
        Group {
            ForEach(chapters, id: \.0) { (chapterType, chapter) in
                NavigationStack {
                    ChapterEditorView(chapter, .constant(true), moc: controller.viewContext)
                }
                .previewDisplayName("Preview for \(chapterType)")

            }
            .environmentObject(AppAlertMessenger())
        }
    }
}
#endif
