//
//  RangeReplaceableCollections.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/28/23.
//

import Foundation

extension RangeReplaceableCollection where Element: Equatable {
    mutating func removeObject(_ element: Element) {
        guard let idx = firstIndex(of: element) else { return }
        remove(at: idx)
    }
}
