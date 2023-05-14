//
//  ChapterCreatorViewModel.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/24/23.
//

import SwiftUI
import CoreData
import CloudStorage

class ChapterCreatorViewModel: ObservableObject {
    private let moc: NSManagedObjectContext
    deinit {
        viewModelLogger.info("Leaving chapter creator rolling back any chapters")
        moc.rollback()
    }

    init(
        _ context: NSManagedObjectContext = PersistenceController.shared.viewContext
    ) {
        moc = context
        guard let previousChapter = try? moc.fetch(Chapter.currentChapter()).first else { return }
        self.previousChapter = previousChapter
        title = previousChapter.title ?? ""
        isVacation = previousChapter.isVacation
        let goals = previousChapter.chapterGoals?
            .compactMap { $0 as? ChapterGoal }
            .sorted(using: SortDescriptor(\ChapterGoal.orderIdx))
            .compactMap { $0.goal } ?? []

        for goal in goals {
            guard !maxGoalsReached else { return }
            chapterGoals.append(goal)
        }
    }

    @CloudStorage(.identityGoalsKey) var goalsMax = 5

    // MARK: -
    // MARK: - Chapter Section
    @Published var title = ""
    @Published var formFocus: ChapterCreatorFormFocus? = .title
    @Published private(set) var chapterGoals: [Goal] = []
    @Published var actionAlert: AppAlert?
    @Published var createdChapter = false
    @Published var isVacation = false
    private var previousChapter: Chapter?

    var isChapterCreatable: Bool {
        return (isVacation || goalsToGo == 0) && !title.isBlank
    }
    var maxGoalsReached: Bool {
        return chapterGoals.count == goalsMax
    }

    var goalsToGo: Int {
        return goalsMax - chapterGoals.count
    }

    func createChapter() {
        guard isChapterCreatable else { return viewLogger.info("Attempted to create invalid goal") }
        do {
            let newChapter = Chapter(context: moc)
            newChapter.title = title.trimmed
            newChapter.isVacation = isVacation
            newChapter.dateStarted = .now
            if !isVacation {
                for (idx, goal) in chapterGoals.enumerated() {
                    let chapterGoal = ChapterGoal(context: moc)
                    chapterGoal.orderIdx = Int64(idx)
                    chapterGoal.chapter = newChapter
                    chapterGoal.goal = goal
                }
            }
            // check if previous chapter attributes were similar
            guard !newChapter.compare(with: previousChapter) else {
                moc.rollback()
                actionAlert = .duplicateChapterAlert
                return
            }

            if let previousChapter = previousChapter, previousChapter.pageCount == 0 {
                moc.delete(previousChapter)
            } else {
                previousChapter?.pages?.forEach { ($0 as? Page)?.isDraft = false }
                previousChapter?.dateEnded = Date.now
            }
            try moc.save()
            createdChapter = true
        } catch let err as NSError {
            actionAlert = .persistenceAlert(err)
            viewModelLogger.contextError(err)
        }
    }

    // NOTE: the sections are broken up now, perhaps they will be refactored
    // to different models at some point in the future

    // MARK: -
    // MARK: - Goals Section
    var goalFetchRequest: NSFetchRequest<Goal> {
        return Goal.goals(notIn: chapterGoals, withTitleLike: goalText)
    }
    @Published var goalText = ""
    var isGoalCreatable: Bool {
        return !goalText.isBlank &&
        (try? moc.count(for: Goal.goalsThatAre(named: goalText))) ?? 0 == 0
    }

    func createGoal() {
        guard isGoalCreatable else { return viewLogger.info("Attempted to create invalid goal") }
        let goal = Goal(context: moc)
        goal.title = goalText.trimmed

        do {
            try moc.save()
            add(goal: goal)
        } catch {
            viewModelLogger.error("\(#function) -> Error creating goal \(error.localizedDescription)")
        }
    }

    @discardableResult
    func add(goal: Goal) -> Bool {
        if chapterGoals.count < goalsMax {
            chapterGoals.append(goal)
            goalText = ""
            return true
        } else {
            actionAlert = .maxGoalsAlert
            return false
        }
    }

    func remove(goal: Goal) {
        chapterGoals.removeObject(goal)
    }

    func moveChapterGoals(from source: IndexSet, to destintation: Int) {
        chapterGoals.move(fromOffsets: source, toOffset: destintation)
    }
}
