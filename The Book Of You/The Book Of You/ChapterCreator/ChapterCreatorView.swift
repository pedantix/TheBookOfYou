//
//  ChapterCreatorView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/21/23.
//

import SwiftUI
import CoreData
import CloudStorage

enum ChapterCreatorFormFocus {
    case title, goalSearch
}

struct ChapterCreatorView: View {
    @EnvironmentObject private var navStore: NavStore
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
            }
            .padding(.fs6)
            vacationToggle
                .padding(.fs6)
            if !viewModel.isVacation {
                chapterGoals
            } else {
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "laurel.leading")
                            .font(.largeTitle)
                        Text("Taking Time Off Provides New Perspective!")
                            .multilineTextAlignment(.center)
                            .bold()
                        Image(systemName: "laurel.trailing")
                            .font(.largeTitle)
                    }
                    .padding()
                    Spacer()
                }
            }

        }
        .onReceive(viewModel.$formFocus) { vmFocus in
            formFocus = vmFocus
        }
        .onAppear {
            formFocus = viewModel.formFocus
        }
        .navigationTitle("Chapter creator")
        .modifier(AppAlertable(viewModel.$actionAlert))
        .onReceive(viewModel.$createdChapter) { created in
            guard created else { return }
            navStore.popBack()
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

    private var vacationToggle: some View {
        Toggle("Taking a vacation?", isOn: $viewModel.isVacation)
            .accessibilityIdentifier("Vacation Toggle")
    }

    private var chapterGoals: some View {
        List {
                Section("Chapter Goals") {
                    if viewModel.chapterGoals.count > 0 {
                        ForEach(viewModel.chapterGoals) { goal in
                            GoalSearchRow(goal: goal)
                                .onTapGesture {
                                    viewModel.remove(goal: goal)
                                }
                        }
                        .onMove { anIndexSet, anInt in
                            viewModel.moveChapterGoals(from: anIndexSet, to: anInt)
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
                    GoalSearchRow(goal: goal).onTapGesture {
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
