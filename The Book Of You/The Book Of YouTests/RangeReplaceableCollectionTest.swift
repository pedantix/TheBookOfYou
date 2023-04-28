//
//  RangeReplaceableCollectionTest.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 4/28/23.
//

import XCTest
@testable import The_Book_Of_You

final class RangeReplaceableCollectionTest: XCTestCase {

    func testRemovesObjectsAtFirstRange() {
        let interesting = 1
        var collection = [0, 5, interesting, 6, 93, interesting, 35]
        XCTAssertTrue(collection.contains(where: { $0 == interesting }))
        collection.removeObject(interesting)
        XCTAssertTrue(collection.contains(where: { $0 == interesting }))
        collection.removeObject(interesting)
        XCTAssertFalse(collection.contains(where: { $0 == interesting }))
    }

}
