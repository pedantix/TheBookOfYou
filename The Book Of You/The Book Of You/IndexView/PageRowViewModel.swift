//
//  PageRowViewModel.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 5/8/23.
//

import Foundation

struct PageRowViewModel {
    private static let dateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    let page: Page

    init(page: Page) {
        self.page = page
    }

    var entryDate: String {
        if let date = page.entryDate {
            return PageRowViewModel.dateFormatter.string(from: date)
        } else {
            return "No Entry Date Recorded"
        }
    }

    var pageUrl: URL {
        return page.objectID.uriRepresentation()
    }

    var isVacation: Bool {
        return page.vacationDay
    }
}
