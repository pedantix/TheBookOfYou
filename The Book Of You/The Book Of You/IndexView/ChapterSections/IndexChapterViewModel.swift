//
//  IndexChapterViewModel.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/20/23.
//

import Foundation

class IndexChapterViewModel: ObservableObject, Identifiable {
    var id: ObjectIdentifier {
        return chapter.id
    }

    let chapter: Chapter
    init(chapter: Chapter) {
        self.chapter = chapter
    }
}

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.current
    dateFormatter.dateStyle = .medium
    return dateFormatter
}()

extension IndexChapterViewModel {
    var title: String {
        return chapter.title ?? "NO TITLE FOUND FOR RECORD"
    }

    var startDate: String {
        if let aDate = chapter.dateStarted {
            return dateFormatter.string(from: aDate)
        } else {
            return "NO START DATE FOUND FOR RECORD"
        }
    }

    var chapterHeading: String {
        return "\(title) - \(startDate) - \(endDate)"
    }

    var endDate: String {
        if let aDate = chapter.dateEnded {
            return dateFormatter.string(from: aDate)
        } else {
            return "present"
        }
    }

    var dateBlock: String {
        return "\(startDate) - \(endDate)"
    }

    var chapterIsEnded: Bool {
        return chapter.dateEnded != nil
    }
}
