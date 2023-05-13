//
//  PageEditorViewModelTests.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 5/1/23.
//

import XCTest
@testable import The_Book_Of_You

final class PageEditorViewModelTests: BackgroundContextTestCase {
    private var vacationPage: Page!
    private var pageWithTwoEntries: Page!
    private var validatorGraph: StubValidatorGraph!

    override func setUp() async throws {
        try await super.setUp()
        vacationPage = context.addVacationPage()
        pageWithTwoEntries = context.addPage(goals: 2)
        validatorGraph = .init()
    }
}

// MARK: - Presentation of Page
extension PageEditorViewModelTests {
    func testPresentationOfVacationChapter() {
        let viewModel = PageEditorViewModel(vacationPage, validatorGraph)
        XCTAssertEqual(viewModel.entries, [.freeText(vacationPage, [])])
    }

    func testPresentationOfGoalChapter() {
        let viewModel = PageEditorViewModel(pageWithTwoEntries, validatorGraph)
        XCTAssertEqual(viewModel.entries, getEntriesFor(pageWithTwoEntries))
        XCTAssertEqual(viewModel.entries.count, 3)
    }

    func testPresentationOfGoalChapterWhenInVacationMode() {
        pageWithTwoEntries.vacationDay = true
        let viewModel = PageEditorViewModel(pageWithTwoEntries, validatorGraph)
        XCTAssertEqual(viewModel.entries, [.freeText(pageWithTwoEntries, [])])
        XCTAssertEqual(viewModel.entries.count, 1)
    }

    private func getEntriesFor(_ page: Page) -> [PageEditorViewModel.Entry] {
        let goals = page.chapter?.goals ?? []
        let textEntries = page.pageEntries?
            .compactMap { $0 as? PageEntry }
            .sorted { $0.entryOrder < $1.entryOrder }
            .compactMap { $0.textEntry } ?? []

        return zip(goals, textEntries).map { goal, textEntry in
            PageEditorViewModel.Entry.text(goal, textEntry, [])
        } +  [.freeText(page, [])]

    }
}

// MARK: - Errors on Page as a result to try to save
extension PageEditorViewModelTests {
    func testErrorsAreAddIfValidatorReturnsThemForPage() {
        let error = PageValidationError.fieldErrors([.blankJournalOnVacationDay])
        validatorGraph.fakePageValidator.mockResult = .failure(error)
        let viewModel = PageEditorViewModel(vacationPage, validatorGraph)
        XCTAssertEqual(viewModel.entries, [.freeText(vacationPage, [])])
        XCTAssertTrue(pageWithTwoEntries.isDraft)
        viewModel.attemptToUpdateDraft()
        XCTAssertEqual(viewModel.entries, [.freeText(vacationPage, [.blankJournalOnVacationDay])])
        XCTAssertTrue(pageWithTwoEntries.isDraft)
    }

    func testErrorsAreAddIfValidatorReturnsThemForPageEntries() {
        var targetGoal: Goal!
        var targetTextEntry: TextEntry!
        var pageEntry: PageEntry!

        let initialEntries = getEntriesFor(pageWithTwoEntries)
        let indexToSwitch = initialEntries.firstIndex { entry in
            switch entry {
            case let.text(goal, textEntry, _):
                targetGoal = goal
                targetTextEntry = textEntry
                return true
            default:
                return false
            }
        } ?? 0

        pageEntry = targetTextEntry.pageEntry!
        var expectedEntries = initialEntries
        let pageEntryValidationError = PageEntryValidationError.textEntry(.emptyText)
        expectedEntries[indexToSwitch] = .text(targetGoal, targetTextEntry, [pageEntryValidationError])

        let pageEntriesValidationError = PageEntriesValidationError.entryValidation(
            [pageEntry: [pageEntryValidationError]]
        )
        let fieldError = PageValidationFieldError.pageEntriesValidationError(pageEntriesValidationError)
        let error = PageValidationError.fieldErrors([fieldError])
        validatorGraph.fakePageValidator.mockResult = .failure(error)
        let viewModel = PageEditorViewModel(pageWithTwoEntries, validatorGraph)

        XCTAssertEqual(viewModel.entries, initialEntries)
        XCTAssertTrue(pageWithTwoEntries.isDraft)
        viewModel.attemptToUpdateDraft()

        XCTAssertEqual(viewModel.entries, expectedEntries)
        XCTAssertTrue(pageWithTwoEntries.isDraft)
    }

    func testClearErrorForEntry() {
        let error = PageValidationError.fieldErrors([.blankJournalOnVacationDay])
        validatorGraph.fakePageValidator.mockResult = .failure(error)
        let initialEntry = PageEditorViewModel.Entry.freeText(vacationPage, [.blankJournalOnVacationDay])
        let expectedEntry = PageEditorViewModel.Entry.freeText(vacationPage, [])
        let viewModel = PageEditorViewModel(vacationPage, validatorGraph)

        viewModel.entries = [initialEntry]
        viewModel.clearError(for: initialEntry)
        XCTAssertEqual(viewModel.entries, [expectedEntry])
    }
}

// MARK: - Successful Save
extension PageEditorViewModelTests {
    func testSuccessfulUpdate() {
        let viewModel = PageEditorViewModel(vacationPage, validatorGraph)
        let vacationPageId = vacationPage.objectID
        try XCTAssertTrue((context.existingObject(with: vacationPageId) as? Page)?.isDraft ?? false)
        viewModel.attemptToUpdateDraft()
        XCTAssertTrue(viewModel.isPageUpdateToNonDraftForm)
        try XCTAssertFalse((context.existingObject(with: vacationPageId) as? Page)?.isDraft ?? true)
    }
}

// MARK: - Handle Will Disappear
extension PageEditorViewModelTests {
    func testDraftIsSaved() {
        let newPage = Page(context: context)
        let oldDate = Date.date(daysAgo: 5)
        newPage.lastModifiedAt = oldDate
        XCTAssertEqual((context.object(with: newPage.objectID) as? Page)?.lastModifiedAt, oldDate)
        let viewModel = PageEditorViewModel(newPage, validatorGraph)
        viewModel.viewDismissing()
        XCTAssertNotEqual((context.object(with: newPage.objectID) as? Page)?.lastModifiedAt, oldDate)
    }

    func testPublishedIsNotSavedOnDismiss() {
        let newPage = Page(context: context)
        let oldDate = Date.date(daysAgo: 5)
        newPage.lastModifiedAt = oldDate
        newPage.isDraft = false
        XCTAssertEqual((context.object(with: newPage.objectID) as? Page)?.lastModifiedAt, oldDate)
        let viewModel = PageEditorViewModel(newPage, validatorGraph)
        viewModel.viewDismissing()
        XCTAssertEqual((context.object(with: newPage.objectID) as? Page)?.lastModifiedAt, oldDate)
    }
}
