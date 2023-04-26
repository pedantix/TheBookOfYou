//
//  GoalViewModel.swift
//  The Book Of You
//
//  Created by Shaun Hubbard on 4/24/23.
//

import Foundation

struct GoalViewModel {
    let goal: Goal

    var title: String {
        return goal.title ?? "BAD GOAL, NO TITLE"
    }
}
