//
//  SwipeGesture.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/9/22.
//

import SwiftUI

public enum SwipeDirection: String {
    case left, right, up, down, none
}

public extension DragGesture.Value {
    func detectDirection() -> SwipeDirection {
        if self.startLocation.x < self.location.x - 24 {
            return .left
        }
        if self.startLocation.x > self.location.x + 24 {
            return .right
        }
        if self.startLocation.y < self.location.y - 24 {
            return .down
        }
        if self.startLocation.y > self.location.y + 24 {
            return .up
        }
        return .none
    }
}
