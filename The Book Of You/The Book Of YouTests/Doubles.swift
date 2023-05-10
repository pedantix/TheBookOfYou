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

struct DummyAlertMessenger: AlertMessenger {
    func displayNewAlert(_ data: AppAlert) {
        /* noop */
    }
}

class StubValidatorGraph: ValidatorGraph {
   var chapterValidator: ChapterValidator = ChapterValidator()

    lazy var fakePageValidator = FakePageValidator(pageEntriesValidator)
    lazy var fakePageEntriesValidator = FakePageEntriesValidator(textEntryValidator)
    var fakeTextEntryValidator = FakeTextEntriesValidator()

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

class StubModelServices: ModelServiceGraph {
    var pageCreatorService: PageCreatorService = FakePageCreatorService(
        viewContext: PersistenceController(inMemory: true).viewContext
    )

    var modelRepo: ModelRepo = StubModelRepo()
}

enum StubError: Error {
case methodNotStubbed
}

class StubModelRepo: ModelRepo {
    var mockPage: Page?
    var mockChapter: Chapter?

    func fetchPage(by url: URL) throws -> Page {
        guard let page = mockPage else { throw StubError.methodNotStubbed }
        return page
    }

    func fetchChapter(by url: URL) throws -> Chapter {
        guard let chap = mockChapter else { throw StubError.methodNotStubbed }
        return chap
    }
}

class FakePageCreatorService: PageCreatorService {
    var pageResult: Result<Page, Error> = .failure(NSError(domain: "No error", code: 101))

    override func createPage(for chapter: Chapter) throws -> Page {
        switch pageResult {
        case .success(let page):
            return page
        case .failure(let err):
            throw err
        }
    }
}

class FakePageValidator: PageValidator {
    var mockResult: Result<Bool, PageValidationError> = .success(true)

    override func validate(_ page: Page) -> Result<Bool, PageValidationError> {
        return mockResult
    }
}

class FakeTextEntriesValidator: TextEntryValidator {
    var mockResult: Result<Bool, TextValidationError> = .success(true)

    override func validate(_ textEntry: TextEntry) -> Result<Bool, TextValidationError> {
        return mockResult
    }
}

class FakePageEntriesValidator: PageEntriesValidator {
    var mockResult: Result<Bool, PageEntriesValidationError> = .success(true)

    override func validate(_ pageEntriesSet: NSSet) -> Result<Bool, PageEntriesValidationError> {
        return mockResult
    }
}
