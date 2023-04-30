//
//  ChapterCreatorView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/21/23.
//

import SwiftUI
import CoreData
import CloudStorage

// TODO: navigation needs work... navigating directly to the destination creates a funky path
enum ChapterCreatorFormFocus {
    case title, goalSearch
}

struct ChapterCreatorView: View {
    @EnvironmentObject private var navStore: NavStore
    @EnvironmentObject private var messenger: AppAlertMessenger
    @StateObject private var viewModel = ChapterCreatorViewModel()
    @FocusState private var formFocus: ChapterCreatorFormFocus?
    @CloudStorage(.identityGoalsKey) private var goals: Int?

    var body: some View {
        VStack {
            TextField(
                "Chapter Title - Editable In the Future",
                text: $viewModel.title
            )
            .submitLabel(.done)
            .focused($formFocus, equals: .title)
            .onSubmit {
                viewModel.formFocus = .none
            }.padding(.fs6)
            chapterGoals

        }
        .onReceive(viewModel.$formFocus) { vmFocus in
            formFocus = vmFocus
        }
        .onAppear {
            formFocus = viewModel.formFocus
        }
        .navigationTitle("Chapter creator")
        .onReceive(viewModel.$actionAlert) { actionAlert in
            guard let actionAlert = actionAlert else { return }
            messenger.displayNewAlert(actionAlert)
        }
        .onReceive(viewModel.$destination) { destination in
            guard let destination = destination else { return }
            navStore.navigate(to: destination)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    viewModel.createChapter()
                }
                .disabled(!viewModel.isChapterCreatable)
            }
        }
    }

    private var chapterGoals: some View {
        List {
                Section("Chapter Goals") {
                    if viewModel.chapterGoals.count > 0 {
                        ForEach(viewModel.chapterGoals) { goal in
                            GoalSearchRow(goal: goal, alertMessenger: messenger)
                                .onTapGesture {
                                    viewModel.remove(goal: goal)
                                }
                        }
                    } else {
                        Text("No goals selected yet, you need \(goals ?? 1) based on the settings" +
                             " in the intro section to create a chapter," +
                             " search create and drag drop goals from below.")
                    }
                }
            Section("What part of you might you want to amplify?") {
                TextField(
                    "New goal, think big picture",
                    text: $viewModel.goalText
                )
                .submitLabel(.done)
                .focused($formFocus, equals: .goalSearch)
                .onSubmit {
                    viewModel.createGoal()
                    viewModel.formFocus = .none
                }.padding(.fs6)
                FilteredFetchRequest(fetchRequest: viewModel.goalFetchRequest) { goal in
                    GoalSearchRow(goal: goal, alertMessenger: messenger).onTapGesture {
                        viewModel.add(goal: goal)
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

struct ChapterCreatorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChapterCreatorView()
        }
    }
}
