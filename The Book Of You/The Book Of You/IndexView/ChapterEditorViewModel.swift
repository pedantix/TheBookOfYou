//
//  ChapterEditorViewModel.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 5/8/23.
//

import CoreData
import SwiftUI

class ChapterEditorViewModel: ObservableObject {
    private let chapter: Chapter
    private let moc: NSManagedObjectContext
    private let validator: ChapterValidator

    var goals: [Goal] {
        return chapter.goals
    }

    var isVacation: Bool {
        chapter.isVacation
    }

    @Published var editorTitle: String
    @Published var alertData: AppAlert?
    @Published var didSave: Bool = false

    init(
        _ chapter: Chapter,
        moc: NSManagedObjectContext,
        validatorGraph: ValidatorGraph = The_Book_Of_YouApp.prodGraph.validatorGraph
    ) {
        self.moc = moc
        self.chapter = chapter
        editorTitle = chapter.title ?? "BLANK TITLE ERROR"
        validator = validatorGraph.chapterValidator
    }

    func saveChapter() {
        chapter.title = editorTitle.trimmed
        switch validator.validate(chapter) {
        case .success:
            do {
                try moc.save()
                didSave = true
            } catch let error as NSError {
                alertData = .persistenceAlert(error)
                viewModelLogger.contextError(error)
            }
        case .failure(let error):
            for error in error.fieldErrors {
                switch error {
                case .blankTitle:
                    alertData = .blankChapterTitleAlert
                    moc.rollback()
                case .tooFewGoals, .untrimmedTitle:
                    // this should be irrelevant
                    break
                }
            }
        }
    }
}
