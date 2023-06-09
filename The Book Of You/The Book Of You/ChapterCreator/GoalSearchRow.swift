//
//  GoalRow.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/25/23.
//

import SwiftUI

struct GoalSearchRow: View {
    @ObservedObject private var goalViewModel: GoalViewModel
    @FocusState private var focused: Bool

    init(goal: Goal) {
        goalViewModel = .init(goal: goal)
    }

    var body: some View {
        if goalViewModel.isEditing {
            editingBody
                .modifier(AppAlertable(goalViewModel.$appAlert))
        } else {
            displayBody
                .modifier(AppAlertable(goalViewModel.$appAlert))
        }
    }

    private var editingBody: some View {
        TextField("Goal title", text: $goalViewModel.editableTitle)
            .submitLabel(.done)
            .focused($focused)
            .onSubmit {
                goalViewModel.saveEdit()
            }
            .onReceive(goalViewModel.$isEditing) { val in
                focused = val
            }
    }

    private var displayBody: some View {
        ZStack {
            ClickableBackgroundView("Goal Row: \(goalViewModel.title)")
            HStack {
                Text(goalViewModel.title)
                Spacer()
            }
        }.padding()
            .swipeActions {
                if goalViewModel.isDeletable {
                    Button("Delete") {
                        goalViewModel.delete()
                    }
                    .tint(.red)
                }
                Button("Edit") {
                    goalViewModel.isEditing = true
                }
                .tint(.blue)
            }
            .deleteDisabled(!goalViewModel.isDeletable)
    }
}

#if DEBUG
struct GoalRow_Previews: PreviewProvider {
    private static let persistenceController = PersistenceController.preview
    private static let messenger = AppAlertMessenger()

    static var previews: some View {
        let goal = persistenceController.viewContext.addGoal()
        let chapter = persistenceController.viewContext.addChapters(1).first!
        let nonDeletableGoal = persistenceController.viewContext.addGoal("Another Worhty Goal", with: chapter)
        List {
            ForEach([goal, nonDeletableGoal]) {
                GoalSearchRow(goal: $0)
            }
        }
        .environment(\.managedObjectContext, persistenceController.viewContext)
        .listStyle(.plain)
        .environmentObject(messenger)
    }
}
#endif
