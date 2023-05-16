//
//  TextEditorViewModelTests.swift
//  The Book Of YouTests
//
//  Created by Shaun Hubbard on 5/4/23.
//

import XCTest
@testable import The_Book_Of_You

final class TextEditorViewModelTests: XCTestCase {
    private let basicSampleText = "Lorem Ipsum"
    private let basicErrorText = "Error Lorem Ipsum"
    private var commitedText = ""

    class TestViewModel: TextEditorViewModel {
        var commitBlock: ((String) -> Void)

        init(
            text: String,
            errorText: String,
            commitBlock: @escaping (String) -> Void
        ) {
            self.commitBlock = commitBlock
            super.init(text: text, errorText: errorText)
        }

        override func persistEdit(_ newText: String) {
            commitBlock(newText)
        }
    }

    func testInitializingInitalData() {
        let viewModel = TestViewModel(text: "", errorText: "") { [weak self] in
            self?.commitedText = $0
        }
        XCTAssertEqual(viewModel.editorText, "")
        XCTAssertEqual(viewModel.displayText, "")
        XCTAssertEqual(viewModel.errorText, "")

        let viewModel2 = TextEditorViewModel(text: basicSampleText, errorText: "")
        XCTAssertEqual(viewModel2.editorText, basicSampleText)
        XCTAssertEqual(viewModel2.displayText, basicSampleText)
        XCTAssertEqual(viewModel2.errorText, "")

        let viewModel3 = TestViewModel(
            text: basicSampleText,
            errorText: basicErrorText) { [weak self] in
                self?.commitedText = $0
            }
        XCTAssertEqual(viewModel3.editorText, basicSampleText)
        XCTAssertEqual(viewModel3.displayText, basicSampleText)
        XCTAssertEqual(viewModel3.errorText, basicErrorText)
    }

    func testCommitEditingOfEmptyString() {
        let viewModel = TestViewModel(text: "", errorText: "") { [weak self] in
            self?.commitedText = $0
        }
        XCTAssertEqual(viewModel.editorText, "")
        viewModel.commitEdit()
        XCTAssertEqual(viewModel.displayText, "")
        viewModel.editorText = " "
        viewModel.commitEdit()
        XCTAssertEqual(viewModel.displayText, "")
        viewModel.editorText = "\n "
        viewModel.commitEdit()
        XCTAssertEqual(viewModel.displayText, "")
        viewModel.editorText = "\t"
        viewModel.commitEdit()
        XCTAssertEqual(viewModel.displayText, "")
    }

    func testCommitEditingOfStrings() {
        let viewModel = TestViewModel(text: "", errorText: "") { [weak self] in
            self?.commitedText = $0
        }
        viewModel.isShowingEditor.toggle()
        XCTAssertEqual(viewModel.displayText, "")
        viewModel.editorText = "a string"
        viewModel.commitEdit()
        XCTAssertFalse(viewModel.isShowingEditor)

        viewModel.isShowingEditor.toggle()
        XCTAssertEqual(viewModel.displayText, "a string")
        XCTAssertEqual(commitedText, "a string")
        viewModel.editorText = " spacey \t string\t"
        viewModel.commitEdit()
        XCTAssertEqual(viewModel.displayText, "spacey \t string")
        XCTAssertEqual(viewModel.editorText, "spacey \t string")
        XCTAssertEqual(commitedText, "spacey \t string")
        XCTAssertFalse(viewModel.isShowingEditor)
    }

    func testClearsErrorOnTyping() {
        let viewModel = TestViewModel(
            text: basicSampleText,
            errorText: basicErrorText) { [weak self] in
                self?.commitedText = $0
            }
        XCTAssertEqual(viewModel.editorText, basicSampleText)
        XCTAssertEqual(viewModel.displayText, basicSampleText)
        XCTAssertEqual(viewModel.errorText, basicErrorText)

        viewModel.editorText += " some text"
        XCTAssertEqual(viewModel.editorText, basicSampleText + " some text")
        XCTAssertEqual(viewModel.displayText, basicSampleText)
        XCTAssertEqual(viewModel.errorText, "")
    }

    func testShowEditorMaintainsDirtyText() {
        let viewModel = TestViewModel(
            text: basicSampleText,
            errorText: basicErrorText) { [weak self] in
                self?.commitedText = $0
            }
        viewModel.editorText += " dirty"

        XCTAssertNotEqual(viewModel.displayText, viewModel.editorText)
        XCTAssertFalse(viewModel.isShowingEditor)

        viewModel.isShowingEditor.toggle()

        XCTAssertNotEqual(viewModel.displayText, viewModel.editorText)
    }
}

final class PageFreeTextEditorViewModelTests: BackgroundContextTestCase {
    private var page: Page!

    override func setUp() async throws {
        try await super.setUp()
        page = context.addPage()
    }

    func testTextSetup() {
        let viewModel = PageFreeTextEditorViewModel(page, [], context)

        XCTAssertEqual(viewModel.editorText, "")

        page.journalEntry = "with some Text"
        let viewModel2 = PageFreeTextEditorViewModel(page, [], context)

        XCTAssertEqual(viewModel2.editorText, "with some Text")
    }

    func testErrorTransformation() {
        let viewModel = PageFreeTextEditorViewModel(page, [], context)
        XCTAssertEqual(viewModel.errorText, "")

        let viewModel2 = PageFreeTextEditorViewModel(page, [.blankJournalOnVacationDay], context)
        XCTAssertEqual(viewModel2.errorText, "To add this entry please write some text.")

        let viewModel3 = PageFreeTextEditorViewModel(page, [.untrimmedJournalText], context)
        XCTAssertEqual(
            viewModel3.errorText,
            "There is an error with development logic, text is not being trimmed please contact the developer."
        )
    }

    func testSavingText() {
        let viewModel = PageFreeTextEditorViewModel(page, [], context)
        XCTAssertEqual(viewModel.errorText, "")
        viewModel.editorText = "some text "
        XCTAssertFalse(context.hasChanges)
        XCTAssertEqual(page.journalEntry, nil)
        viewModel.commitEdit()
        XCTAssertFalse(context.hasChanges)
        XCTAssertEqual(page.journalEntry, "some text")
    }

    func testSavingJournalChangesObservedGoalText() async throws {
        page.journalEntry = "Some Text"
        let viewModel = PageFreeTextEditorViewModel(page, [], context)
        XCTAssertEqual(viewModel.editorText, "Some Text")

        let updateExpectation = expectation(description: "Wait for update")
        let theNewText = "new texts"
        let cannelable = viewModel.$displayText.sink { newTxt in
            guard newTxt == theNewText else { return }
            updateExpectation.fulfill()
        }

        page.journalEntry = theNewText
        try context.save()
        await fulfillment(of: [updateExpectation], timeout: 2)
        XCTAssertEqual(viewModel.displayText, theNewText)
        XCTAssertEqual(viewModel.editorText, theNewText)
        cannelable.cancel()
    }
}

final class GoalTextEditorViewModellTests: BackgroundContextTestCase {
    private var goal: Goal!
    private var textEntry: TextEntry!
    override func setUp() async throws {
        try await super.setUp()
        let page = context.addPage(goals: 1)
        goal = page.chapter?.goals.first
        textEntry = page.pageEntries?.compactMap { $0 as? PageEntry }.compactMap { $0.textEntry }.first
    }

    func testTextSetup() {
        let viewModel = GoalTextEditorViewModel(goal, textEntry, [], context)

        XCTAssertEqual(viewModel.editorText, "")

        textEntry.text = "with some Text"
        let viewModel2 = GoalTextEditorViewModel(goal, textEntry, [], context)

        XCTAssertEqual(viewModel2.editorText, "with some Text")
    }

    func testErrorTransformation() {
        let viewModel = GoalTextEditorViewModel(goal, textEntry, [], context)
        XCTAssertEqual(viewModel.errorText, "")

        let viewModel2 = GoalTextEditorViewModel(goal, textEntry, [.textEntry(.emptyText)], context)
        XCTAssertEqual(viewModel2.errorText, "To add this entry please write some text.")

        let viewModel3 = GoalTextEditorViewModel(goal, textEntry, [.textEntry(.untrimmedText)], context)
        XCTAssertEqual(
            viewModel3.errorText,
            "There is an error with development logic, text is not being trimmed please contact the developer."
        )
    }

    func testSavingText() {
        let viewModel = GoalTextEditorViewModel(goal, textEntry, [], context)
        XCTAssertEqual(viewModel.errorText, "")
        viewModel.editorText = "some text "
        XCTAssertFalse(context.hasChanges)
        XCTAssertEqual(textEntry.text, nil)
        viewModel.commitEdit()
        XCTAssertFalse(context.hasChanges)
        XCTAssertEqual(textEntry.text, "some text")
    }

    func testSavingGoalChangesObservedGoalText() async throws {
        textEntry.text = "Some Text"
        let viewModel = GoalTextEditorViewModel(goal, textEntry, [], context)
        XCTAssertEqual(viewModel.editorText, "Some Text")

        let updateExpectation = expectation(description: "Wait for update")
        let theNewText = "new texts"
        let cannelable = viewModel.$displayText.sink { newTxt in
            guard newTxt == theNewText else { return }
            updateExpectation.fulfill()
        }

        textEntry.text = theNewText
        try context.save()
        await fulfillment(of: [updateExpectation], timeout: 2)
        XCTAssertEqual(viewModel.displayText, theNewText)
        XCTAssertEqual(viewModel.editorText, theNewText)
        cannelable.cancel()
    }
}
