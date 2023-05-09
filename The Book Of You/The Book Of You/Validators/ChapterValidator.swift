//
//  ChapterValidator.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 5/8/23.
//

import Foundation
import CloudStorage

struct ChapterValidatorError: Error, Equatable {
    let fieldErrors: [ChapterValidatorFieldError]
}

enum ChapterValidatorFieldError: Error { case tooFewGoals, blankTitle, untrimmedTitle }

class ChapterValidator: Validator {
    @CloudStorage(.identityGoalsKey) var identityGoalsCount: Int = 5

    func validate(_ chapter: Chapter) -> Result<Bool, ChapterValidatorError> {
        var fieldErrors = [ChapterValidatorFieldError]()
        validateTitle(chapter, fieldErrors: &fieldErrors)
        goalsValidator(chapter, fieldErrors: &fieldErrors)
        if fieldErrors.isEmpty {
            return .success(true)
        }
        return .failure(.init(fieldErrors: fieldErrors))
    }

    private func validateTitle(_ chapter: Chapter, fieldErrors: inout [ChapterValidatorFieldError]) {
        guard let title = chapter.title else {
            fieldErrors.append(.blankTitle)
            return
        }

        if title.isBlank {
            fieldErrors.append(.blankTitle)
        } else if title.trimmed != title {
            fieldErrors.append(.untrimmedTitle)
        }
    }

    private func goalsValidator(_ chapter: Chapter, fieldErrors: inout [ChapterValidatorFieldError]) {
        guard !chapter.isVacation else { return }
        if (chapter.chapterGoals?.count ?? 0) != identityGoalsCount {
            fieldErrors.append(.tooFewGoals)
        }
    }
}
