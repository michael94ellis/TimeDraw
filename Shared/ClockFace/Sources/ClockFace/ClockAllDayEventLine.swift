//
//  ClockAllDayEventLine.swift
//  TimeDraw
//

import SwiftUI

public struct ClockAllDayEventLine: Shape {
    let startDegrees: Double
    let endDegrees: Double
    let radius: CGFloat
    
    public init(startDegrees: Double,
                endDegrees: Double,
                radius: CGFloat) {
        self.startDegrees = startDegrees
        self.endDegrees = endDegrees
        self.radius = radius
    }

    public func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        
        path.addEllipse(in: CGRect(
            x: center.x - radius,
            y: center.y - radius,
            width: radius * 2,
            height: radius * 2
        ))
        
        return path
    }
}
