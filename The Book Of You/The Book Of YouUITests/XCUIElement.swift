//
//  XCUIElement.swift
//  The Book Of YouUITests
//
//  Created by Shaun Hubbard on 7/2/23.
//

import XCTest

extension XCUIElement {
    func swipeUpUntilElementFound(app: XCUIApplication,
                                  velocity: XCUIGestureVelocity = .default,
                                  maxNumberOfSwipes: UInt = 50) -> Bool {

        guard !self.isHittable else { return true }

        for _ in 1...maxNumberOfSwipes {
            app.swipeUp(velocity: velocity)
            if self.isHittable {
                return true
            }
        }

        return false
    }
}
