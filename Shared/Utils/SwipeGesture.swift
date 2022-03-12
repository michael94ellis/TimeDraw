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
    func detectDirection(_ tolerance: CGFloat = 24) -> SwipeDirection {
        if self.startLocation.x < self.location.x - tolerance {
            return .left
        }
        if self.startLocation.x > self.location.x + tolerance {
            return .right
        }
        if self.startLocation.y < self.location.y - tolerance {
            return .down
        }
        if self.startLocation.y > self.location.y + tolerance {
            return .up
        }
        return .none
    }
}
