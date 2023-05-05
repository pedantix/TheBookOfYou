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
    private lazy var sampleDataEmpty: (String) -> Void = { str in
        self.commitedText = str
    }

    func testInitializingInitalData() {
        let viewModel = TextEditorViewModel(text: "", errorText: "", textCommitAction: sampleDataEmpty)
        XCTAssertEqual(viewModel.editorText, "")
        XCTAssertEqual(viewModel.displayText, "")
        XCTAssertEqual(viewModel.errorText, "")

        let viewModel2 = TextEditorViewModel(text: basicSampleText, errorText: "", textCommitAction: sampleDataEmpty)
        XCTAssertEqual(viewModel2.editorText, basicSampleText)
        XCTAssertEqual(viewModel2.displayText, basicSampleText)
        XCTAssertEqual(viewModel2.errorText, "")

        let viewModel3 = TextEditorViewModel(
            text: basicSampleText,
            errorText: basicErrorText,
            textCommitAction: sampleDataEmpty
        )
        XCTAssertEqual(viewModel3.editorText, basicSampleText)
        XCTAssertEqual(viewModel3.displayText, basicSampleText)
        XCTAssertEqual(viewModel3.errorText, basicErrorText)
    }

    func testCommitEditingOfEmptyString() {
        let viewModel = TextEditorViewModel(text: "", errorText: "", textCommitAction: sampleDataEmpty)
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
        let viewModel = TextEditorViewModel(text: "", errorText: "", textCommitAction: sampleDataEmpty)
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
        let viewModel = TextEditorViewModel(
            text: basicSampleText,
            errorText: basicErrorText,
            textCommitAction: sampleDataEmpty
        )
        XCTAssertEqual(viewModel.editorText, basicSampleText)
        XCTAssertEqual(viewModel.displayText, basicSampleText)
        XCTAssertEqual(viewModel.errorText, basicErrorText)

        viewModel.editorText += " some text"
        XCTAssertEqual(viewModel.editorText, basicSampleText + " some text")
        XCTAssertEqual(viewModel.displayText, basicSampleText)
        XCTAssertEqual(viewModel.errorText, "")
    }

    func testShowEditorMaintainsDirtyText() {
        let viewModel = TextEditorViewModel(
            text: basicSampleText,
            errorText: basicErrorText,
            textCommitAction: sampleDataEmpty
        )
        viewModel.editorText += " dirty"

        XCTAssertNotEqual(viewModel.displayText, viewModel.editorText)
        XCTAssertFalse(viewModel.isShowingEditor)

        viewModel.isShowingEditor.toggle()

        XCTAssertNotEqual(viewModel.displayText, viewModel.editorText)
    }
}
