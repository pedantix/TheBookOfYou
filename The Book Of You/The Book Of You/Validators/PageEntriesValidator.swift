//
//  PageEntriesValidator.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 5/1/23.
//

import Foundation

enum PageEntriesValidationError: Error, Equatable {
    static func == (lhs: PageEntriesValidationError, rhs: PageEntriesValidationError) -> Bool {
        switch (lhs, rhs) {
        case (.entryValidation(let lhsEv), .entryValidation(let rhsEv)):
            return lhsEv == rhsEv
        case (.unknownEntryTypeError, .unknownEntryTypeError):
            return true
        case (.invalidOrderSequence, .invalidOrderSequence):
            return true
        default:
            return false
        }
    }

    case entryValidation([PageEntry: [PageEntryValidationError]])
    case unknownEntryTypeError
    case invalidOrderSequence
}

enum PageEntryValidationError: Error, Equatable {
case textEntry(TextValidationError)
}

class PageEntriesValidator: Validator {
    private let textEntryValidator: TextEntryValidator

    init(_ textEntryValidator: TextEntryValidator) {
        self.textEntryValidator = textEntryValidator
    }

    func validate(_ pageEntriesSet: NSSet) -> Result<Bool, PageEntriesValidationError> {
        var pageEntryErrors = [PageEntry: [PageEntryValidationError]]()
        var orderInts = Set<Int64>()

        for entry in pageEntriesSet {
            guard let pageEntry = entry as? PageEntry,
                  let textEntry = pageEntry.textEntry
            else { return .failure(.unknownEntryTypeError) }
            switch textEntryValidator.validate(textEntry) {
            case let.failure(err):
                pageEntryErrors[pageEntry] = (pageEntryErrors[pageEntry] ?? []) +  [.textEntry(err)]
            case .success:
                break
            }
            orderInts.insert(pageEntry.entryOrder)
        }

        guard orderInts.count == pageEntriesSet.count else {
            return .failure(.invalidOrderSequence)
        }

        if !pageEntryErrors.isEmpty {
            return .failure(.entryValidation(pageEntryErrors))
        }
        return .success(true)
    }
}
