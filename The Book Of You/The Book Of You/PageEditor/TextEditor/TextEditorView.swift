//
//  TextEditorView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 5/4/23.
//

import SwiftUI

struct TextEditorView: View {
    @ObservedObject private var viewModel: TextEditorViewModel
    private let title: String

    init(_ title: String, _ text: String, errorText: String = "", textCommitAction: @escaping (String) -> Void) {
        viewModel = .init(text: text, errorText: errorText, textCommitAction: textCommitAction)
        self.title = title
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title3)
                .padding(.fs4)
            Text(viewModel.displayText)
                .font(.body)
                .padding([.leading, .trailing], .fs4)
            HStack {
                Text(viewModel.errorText)
                    .bold()
                    .foregroundColor(.red)
                Spacer()
                Button {
                    viewModel.isShowingEditor.toggle()

                } label: {
                    Image(systemName: "pencil")
                }.buttonStyle(.borderedProminent)
            }.padding(.fs5)
        }
        .sheet(isPresented: $viewModel.isShowingEditor) {
            NavigationStack {
                VStack {
                    TextEditor(text: $viewModel.editorText)
                        .padding()
                }.navigationTitle("Edit \(title)")
                .navigationBarTitleDisplayMode(.inline)
                .navigationViewStyle(.stack)
                .toolbarRole(.navigationStack)
                .toolbar {
                    ToolbarItemGroup(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) {
                            viewModel.isShowingEditor.toggle()
                        }
                    }

                    ToolbarItemGroup(placement: .confirmationAction) {
                        Button("Update") {
                            viewModel.commitEdit()
                        }
                    }
                }
            }
        }
    }
}

#if DEBUG
struct TextEditorView_Previews: PreviewProvider {
    static var sampleData = [
        ("title", "some text", ""),
        ("title 2", "some more text", "Error!!!")
    ]
    static var previews: some View {
        List {
            ForEach(sampleData, id: \.0) {
                TextEditorView($0.0, $0.1, errorText: $0.2) { _ in
                    // noop
                }
                .listRowSeparator(.hidden)
            }

        }
        .listStyle(.plain)
    }
}
#endif
