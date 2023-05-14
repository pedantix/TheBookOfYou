//
//  PageCreatorViewModel.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/30/23.
//

import CoreData
import SwiftUI
import Combine

class PageEditorViewModel: ObservableObject {
    enum Entry: Equatable, Identifiable {
        var id: URL {
            switch self {
            case .freeText(let page, _):
                return page.objectID.uriRepresentation()
            case .text(let goal, _, _):
                return goal.objectID.uriRepresentation()
            }
        }

        case text(Goal, TextEntry, [PageEntryValidationError])
        case freeText(Page, [PageValidationFieldError])
    }

    private let moc: NSManagedObjectContext
    private let pageValidator: PageValidator
    private var vacationDaySubscription: AnyCancellable?

    @ObservedObject private var page: Page
    @Published var entries: [Entry] = []
    @Published var isPageUpdateToNonDraftForm = false
    @Published var didPageSave = false
    @Published var appAlert: AppAlert?

    init(
        _ page: Page,
        _ dependencyGraph: any ValidatorGraph,
        context: NSManagedObjectContext = PersistenceController.shared.viewContext
    ) {
        self.page = page
        moc = context
        pageValidator = dependencyGraph.pageValidator
        vacationDaySubscription = page
            .publisher(for: \.vacationDay)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.setupEntries()
                }
            }
        self.setupEntries()
    }

    deinit {
        vacationDaySubscription?.cancel()
    }

    @MainActor
    private func setupEntries() {
        viewModelLogger.info("Setting up entries")
        guard !page.vacationDay && !(page.chapter?.isVacation ?? false) else {
            viewModelLogger.info("updating entries")
            entries = [.freeText(page, [])]
            return
        }
        let goals = page.chapter?.goals ?? []
        let textEntries = page.pageEntries?
            .compactMap { $0 as? PageEntry }
            .sorted { $0.entryOrder < $1.entryOrder }
            .compactMap { $0.textEntry } ?? []

        entries = zip(goals, textEntries).map { goal, textEntry in
            PageEditorViewModel.Entry.text(goal, textEntry, [])
        } + [.freeText(page, [])]
    }

    var chapterTitle: String {
        return page.chapter?.title ?? "NO CHAPTER TITLE, Error contact Developer"
    }

    func attemptToUpdateDraft() {
        switch pageValidator.validate(page) {
        case .success:
            setDraftToUpdated()
        case let.failure(fieldErrors):
            processValidationErrors(fieldErrors)
        }
    }

    func viewDismissing() {
        guard page.isDraft else { return }
        do {
            if moc.hasChanges {
                page.lastModifiedAt = .now
            }
            try moc.save()
        } catch {
            appAlert = AppAlert.persistenceAlert(error as NSError)
        }
    }

    private func setDraftToUpdated() {
        do {
            page.lastModifiedAt = .now
            page.isDraft = false
            try moc.save()
            isPageUpdateToNonDraftForm = true
            didPageSave = true
        } catch {
            appAlert = AppAlert.persistenceAlert(error as NSError)
        }
    }

    private func processValidationErrors(_ validationErrors: PageValidationError) {
        entries = entries.map {
            switch $0 {
            case let .freeText(page, _):
                return .freeText(page, validationErrors.getPageErrors())
            case let .text(goal, textEntry, _):
                if let pageEntry = textEntry.pageEntry {
                    return .text(goal, textEntry, validationErrors.getErrorsFor(pageEntry: pageEntry))
                } else {
                    return $0
                }
            }
        }
    }

    /// This method is used to listen for user input and if potentially valid input occurs clears the error
    func clearError(for entry: Entry) {
        entries = entries.map { currentEntry in
            guard entry == currentEntry else { return currentEntry }
            switch entry {
            case let.freeText(page, _):
                return .freeText(page, [])
            case let.text(goal, textEntry, _):
                return .text(goal, textEntry, [])
            }
        }
    }
}
