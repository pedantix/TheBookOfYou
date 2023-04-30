//
//  GoalViewModel.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/24/23.
//

import CoreData
import SwiftUI

class GoalViewModel: ObservableObject {
    @Published var isEditing = false {
        didSet {
            editableTitle = self.goal.title ?? ""
        }
    }
    @Published var editableTitle = ""
    var isSavable: Bool {
        return editableTitle != goal.title &&
        !editableTitle.isBlank
    }

    private let moc: NSManagedObjectContext
    private let alertMessenger: AlertMessenger

    let goal: Goal

    init(
        goal: Goal,
        alertMessenger: AlertMessenger,
        context: NSManagedObjectContext = PersistenceController.shared.viewContext
    ) {
        self.goal = goal
        self.moc = context
        self.alertMessenger = alertMessenger
    }

    var title: String {
        return goal.title ?? "BAD GOAL, NO TITLE"
    }

    var isDeletable: Bool {
        return goal.chapterGoals?.count ?? 0 == 0
    }

    func cancelEdit() {
        isEditing = false
    }

    func saveEdit() {
        defer { isEditing = false }
        guard isSavable else {
            return viewModelLogger.info("Attempted to save an edit that was blank")
        }
        goal.title = editableTitle.trimmed
        do {
            try moc.save()
        } catch let err as  NSError {
            let alert = AppAlert.persistenceAlert(err)
            alertMessenger.displayNewAlert(alert)
            viewModelLogger.contextError(err)
        }
    }

    func delete() {
        defer { isEditing = false }
        guard isDeletable else {
            return viewModelLogger.info("Attempted to dleete non deletable goal")
        }
        do {
            moc.delete(goal)
            try moc.save()
        } catch let err as  NSError {
            let alert = AppAlert.persistenceAlert(err)
            alertMessenger.displayNewAlert(alert)
            viewModelLogger.contextError(err)
        }
    }
}
