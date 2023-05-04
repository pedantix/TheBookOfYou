//
//  TextEntryValidator.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 5/1/23.
//

import Foundation

enum TextValidationError: Error {
    case emptyText
    case untrimmedText
}

class TextEntryValidator: Validator {
    func validate(_ textEntry: TextEntry) -> Result<Bool, TextValidationError> {
        guard let textEntryText = textEntry.text,
              !textEntryText.isBlank else { return .failure(.emptyText) }
        guard textEntryText.trimmed.count == textEntryText.count else {
            return .failure(.untrimmedText)
        }

        return .success(true)
    }
}
