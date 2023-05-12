//
//  TextEditorView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 5/4/23.
//

import SwiftUI

struct TextEditorView: View {
    let title: String
    @ObservedObject private var viewModel: TextEditorViewModel

    init(_ title: String, _ viewModel: TextEditorViewModel) {
        self.viewModel = viewModel
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
        .modifier(AppAlertable(viewModel.$appAlert))
        .listRowSeparator(.hidden)
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
                let viewModel = TextEditorViewModel(text: $0.1, errorText: $0.1)
                TextEditorView($0.0, viewModel)
            }

        }
        .listStyle(.plain)
        .environmentObject(AppAlertMessenger())
    }
}
#endif
