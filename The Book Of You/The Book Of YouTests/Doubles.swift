//
//  Doubles.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 4/29/23.
//

import Foundation
@testable import The_Book_Of_You

// NOTE: In an ideal world this file would not be needed, however I am yet to find a
// test double framework in swift that I acctually like... this is due to an issue with
// reflections, I am curious if the objc runtime could be leveraged to overcome this
// without compromising code quality however I am not at the point  where I want to start
// an OSS project instead of finishing this one. That said if this file grows to
// astronmical sizes then it may prompt me to do some exploration. Ideally I would find
// something like mockito that just works with protocols easily

// Candidates
// https://swiftpackageindex.com/Brightify/Cuckoo, downside generated code complicated etc..
//
// https://swiftpackageindex.com/birdrides/mockingbird, generated code ><, runtime scripts
//
// https://swiftpackageindex.com/MakeAWishFoundation/SwiftyMocky

struct FakeAlertMessenger: AlertMessenger {
    func displayNewAlert(_ data: AppAlert) {
        /* noop */
    }
}

class FakeValidatorGraph: ValidatorGraph {
    lazy var fakePageValidator = MockPageValidator(pageEntriesValidator)
    lazy var fakePageEntriesValidator = MockPageEntriesValidator(textEntryValidator)
    var fakeTextEntryValidator = MockTextEntriesValidator()

    var pageValidator: PageValidator {
        return fakePageValidator
    }
    var pageEntriesValidator: PageEntriesValidator {
        return fakePageEntriesValidator
    }
    var textEntryValidator: TextEntryValidator {
        return fakeTextEntryValidator
    }
}

class MockPageValidator: PageValidator {
    var mockResult: Result<Bool, PageValidationError> = .success(true)

    override func validate(_ page: Page) -> Result<Bool, PageValidationError> {
        return mockResult
    }
}

class MockTextEntriesValidator: TextEntryValidator {
    var mockResult: Result<Bool, TextValidationError> = .success(true)

    override func validate(_ textEntry: TextEntry) -> Result<Bool, TextValidationError> {
        return mockResult
    }
}

class MockPageEntriesValidator: PageEntriesValidator {
    var mockResult: Result<Bool, PageEntriesValidationError> = .success(true)

    override func validate(_ pageEntriesSet: NSSet) -> Result<Bool, PageEntriesValidationError> {
        return mockResult
    }
}
