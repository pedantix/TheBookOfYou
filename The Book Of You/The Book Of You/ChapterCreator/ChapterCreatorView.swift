//
//  ChapterCreatorView.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/21/23.
//

import SwiftUI
import CoreData
import CloudStorage

// TODO: The logical structure of this view should be that it creates or replaces an empty chapter, on creation if a past chapter has pages it will add an end date to it and save it
enum ChapterCreatorFormFocus {
    case title, goal
}

// TODO: Make this more generic friendly in the future when needed
struct FilteredFetchRequest<T: NSManagedObject, Content: View>: View {
    @FetchRequest var fetchRequest: FetchedResults<T>

    let content: (T) -> Content

    var body: some View {
        ForEach(fetchRequest, id: \.self) { managedObject in
            content(managedObject)
        }
    }

    init(fetchRequest: NSFetchRequest<T>, @ViewBuilder content: @escaping (T) -> Content) {
        _fetchRequest = FetchRequest(fetchRequest: fetchRequest)
        self.content = content
    }
}

struct ChapterCreatorView: View {
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
        .onChange(of: viewModel.formFocus) { vmFocus in
            formFocus = vmFocus
        }
        .onAppear {
            formFocus = viewModel.formFocus
        }
        .navigationTitle("Chapter creator")
    }

    private var chapterGoals: some View {
        List {
                Section("Chapter Goals") {
                    if viewModel.chapterGoals.count > 0 {
                        ForEach(viewModel.chapterGoals) { goal in
                            Text("\(goal.title ?? "NO TITLE, BAD GOAL!!!!")")
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
                .focused($formFocus, equals: .goal)
                .onSubmit {
                    viewModel.createGoal()
                    viewModel.formFocus = .none
                }.padding(.fs6)
                FilteredFetchRequest(fetchRequest: viewModel.goalFetchRequest) { goal in
                    Text("\(goal.title ?? "really bad extract")")
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