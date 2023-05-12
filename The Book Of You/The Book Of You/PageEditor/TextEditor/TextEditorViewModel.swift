//
//  TextEditorViewModel.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 5/4/23.
//

import CoreData

private func processErrorsToErrorString(_ errors: [PageEntryValidationError]) -> String {
    var errorText = [String]()

    for error in errors {
        switch error {
        case .textEntry(.emptyText):
            errorText.append("To add this entry please write some text.")
        case .textEntry(.untrimmedText):
            errorText.append(
                "There is an error with development logic, text is not being trimmed please contact the developer."
            )
        }
    }

    return errorText.joined(separator: " ")
}

private func processErrorsToErrorString(_ errors: [PageValidationFieldError]) -> String {
    var errorText = [String]()

    for error in errors {
        switch error {
        case .blankJournalOnVacationDay:
            errorText.append("To add this entry please write some text.")
        case .untrimmedJournalText:
            errorText.append(
                "There is an error with development logic, text is not being trimmed please contact the developer."
            )
        case .lastModifedAtError, .entryDateError, .pageEntriesValidationError:
            break
        }
    }

    return errorText.joined(separator: " ")
}

class GoalTextEditorViewModel: TextEditorViewModel {
    private let moc: NSManagedObjectContext
    private let goal: Goal
    private let textEntry: TextEntry
    init(_ goal: Goal, _ textEntry: TextEntry, _ errors: [PageEntryValidationError], _ moc: NSManagedObjectContext) {
        self.goal = goal
        self.textEntry = textEntry
        self.moc = moc
        super.init(
            text: textEntry.text ?? "",
            errorText: processErrorsToErrorString(errors)
        )
    }

    override func persistEdit(_ newText: String) {
        do {
            textEntry.text = newText
            try moc.save()
        } catch let err as NSError {
            moc.rollback()
            appAlert = .persistenceAlert(err)
        }
    }
}

class PageFreeTextEditorViewModel: TextEditorViewModel {
    private let moc: NSManagedObjectContext
    private let page: Page
    init(_ page: Page, _ errors: [PageValidationFieldError], _ moc: NSManagedObjectContext) {
        self.moc = moc
        self.page = page
        super.init(
            text: page.journalEntry ?? "",
            errorText: processErrorsToErrorString(errors)
        )
    }

    override func persistEdit(_ newText: String) {
        do {
            page.journalEntry = newText
            try moc.save()
        } catch let err as NSError {
            moc.rollback()
            appAlert = .persistenceAlert(err)
        }
    }
}

// MARK: - Base View Model
// NOTE: this was not meant to be used on the view but rather overriden to
// meet needs of different types of text entry uniformally
class TextEditorViewModel: ObservableObject {
    @Published var displayText = ""
    @Published var editorText = "" {
        didSet {
            guard !errorText.isEmpty else { return }
            errorText = ""
        }
    }
    @Published var errorText = ""
    @Published var isShowingEditor = false
    // TODO: Test this get called
    @Published var appAlert: AppAlert?

    init(
        text: String,
        errorText: String
    ) {
        displayText = text
        editorText = text
        self.errorText = errorText
    }

    func commitEdit() {
        guard !editorText.isBlank else { return }
        displayText = editorText.trimmed
        editorText = displayText
        persistEdit(displayText)
        isShowingEditor.toggle()
    }

    /// override to save edit
    func persistEdit(_ newText: String) {
        // noop
    }
}
