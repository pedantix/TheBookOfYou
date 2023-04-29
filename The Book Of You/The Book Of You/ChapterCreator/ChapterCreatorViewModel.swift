//
//  ChapterCreatorViewModel.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/24/23.
//

import SwiftUI
import CoreData
import CloudStorage
// TODO: Test the whole thing!
// TODO: Swiftify the naming conventions
// TODO: create a chapter based on previous chapters
// initalize data based on previous chapters

private let maxGoalsAlert = ActionAlertData(
    title: "Not Added",
    message: "You have already reached the specified number of goals, " +
    "please remove one from current chapter goals with tap to add this goal with a tap.",
    sfSymbolText: "square.3.layers.3d.down.right.slash"
)
// TODO: on deinit make sure to clean context
class ChapterCreatorViewModel: ObservableObject {
    private let moc: NSManagedObjectContext
    init(_ context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        moc = context
    }

    @CloudStorage(.identityGoalsKey) var goalsMax = 5

    // MARK: -
    // MARK: - Chapter Section
    @Published var title = ""
    @Published var formFocus: ChapterCreatorFormFocus? = .title
    @Published private(set) var chapterGoals: [Goal] = []
    @Published var actionAlert: ActionAlertData?

    var isChapterCreatable: Bool {
        return goalsToGo == 0 && !title.isBlank
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
            for (idx, goal) in chapterGoals.enumerated() {
                let chapterGoal = ChapterGoal(context: moc)
                chapterGoal.orderIdx = Int64(idx)
                chapterGoal.chapter = newChapter
                chapterGoal.goal = goal
            }
            try moc.save()
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
            addToChapterGoals(goal)
        } catch {
            viewModelLogger.error("\(#function) -> Error creating goal \(error.localizedDescription)")
        }
    }

    @discardableResult
    func addToChapterGoals(_ goal: Goal) -> Bool {
        if chapterGoals.count < goalsMax {
            chapterGoals.append(goal)
            goalText = ""
            return true
        } else {
            actionAlert = maxGoalsAlert
            return false
        }
    }

    func removeChapterGoal(_ goal: Goal) {
        chapterGoals.removeObject(goal)
    }
}
