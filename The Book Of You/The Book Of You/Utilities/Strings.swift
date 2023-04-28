//
//  Strings.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/24/23.
//

import Foundation

extension String {
    var isBlank: Bool {
        return trimmed.isEmpty
    }

    // TODO: remove this from every where in the code
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
