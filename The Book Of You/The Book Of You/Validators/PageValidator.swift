//
//  PageValidator.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 5/1/23.
//

import Foundation

enum PageValidationError: Error, Equatable {
case fieldErrors([PageValidationFieldError])
}

enum PageValidationFieldError: Error, Equatable {
    case entryDateError, lastModifedAtError, blankJournalOnVacationDay, untrimmedJournalText
    case pageEntriesValidationError(PageEntriesValidationError)
}

extension PageValidationFieldError {
    var isPageRelated: Bool {
        switch self {
        case .entryDateError, .lastModifedAtError, .blankJournalOnVacationDay, .untrimmedJournalText:
            return true
        case .pageEntriesValidationError:
            return false
        }
    }

    func filter(for pageEntry: PageEntry) -> [PageEntryValidationError] {
        switch self {
        case let.pageEntriesValidationError(.entryValidation(dict)):
            return dict[pageEntry] ?? []
        default:
            return []
        }
    }
}

extension PageValidationError {
    private func toFieldErrors() -> [PageValidationFieldError] {
        switch self {
        case let.fieldErrors(errors):
            return errors
        }
    }

    func getPageErrors() -> [PageValidationFieldError] {
        return toFieldErrors().filter { $0.isPageRelated }
    }

    func getErrorsFor(pageEntry: PageEntry) -> [PageEntryValidationError] {
        return toFieldErrors().flatMap { $0.filter(for: pageEntry) }
    }
}

class PageValidator: Validator {
    private let pageEntriesValidator: PageEntriesValidator

    init(_ pageEntriesValidator: PageEntriesValidator) {
        self.pageEntriesValidator = pageEntriesValidator
    }

    func validate(_ page: Page) -> Result<Bool, PageValidationError> {
        var fieldErrors = [PageValidationFieldError]()

        validateTimeStamps(page, fieldErrors: &fieldErrors)
        validateVacationDays(page, fieldErrors: &fieldErrors)
        validateJournalText(page, fieldErrors: &fieldErrors)
        validatePageEntries(page, fieldErrors: &fieldErrors)

        if fieldErrors.isEmpty {
            return .success(true)
        } else {
            return .failure(.fieldErrors(fieldErrors))
        }

    }

    private func validatePageEntries(_ page: Page, fieldErrors: inout [PageValidationFieldError]) {
        guard let pageEntries = page.pageEntries else { return }
        switch pageEntriesValidator.validate(pageEntries) {
        case .success:
            break
        case let.failure(validationError):
            fieldErrors.append(.pageEntriesValidationError(validationError))
        }
    }

    private func validateTimeStamps(_ page: Page, fieldErrors: inout [PageValidationFieldError]) {
        if page.entryDate == .none {
            fieldErrors.append(.entryDateError)
        }
        if page.lastModifiedAt == .none {
            fieldErrors.append(.lastModifedAtError)
        }
    }

    private func validateVacationDays(_ page: Page, fieldErrors: inout [PageValidationFieldError]) {
        guard page.vacationDay else { return }
        guard let text = page.journalEntry, !text.isBlank else {
            fieldErrors.append(.blankJournalOnVacationDay)
            return
        }
    }

    private func validateJournalText(_ page: Page, fieldErrors: inout [PageValidationFieldError]) {
        if let text = page.journalEntry, !text.isBlank && text.trimmed.count != text.count {
            fieldErrors.append(.untrimmedJournalText)
        }
    }
}
