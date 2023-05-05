//
//  TextEditorViewModel.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 5/4/23.
//

import Foundation

class TextEditorViewModel: ObservableObject {
    @Published var displayText = ""
    @Published var editorText = "" {
        didSet {
            guard !errorText.isEmpty else { return }
            errorText = ""
        }
    }
    @Published var errorText = ""
    @Published var isShowingEditor = false
    private let commitBlock: (String) -> Void

    init(
        text: String,
        errorText: String,
        textCommitAction: @escaping (String) -> Void
    ) {
        commitBlock  = textCommitAction
        displayText = text
        editorText = text
        self.errorText = errorText
    }

    func commitEdit() {
        guard !editorText.isBlank else { return }
        displayText = editorText.trimmed
        editorText = displayText
        commitBlock(displayText)
        isShowingEditor.toggle()
    }
}
