//
//  ClockEventLine.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/16/22.
//

import SwiftUI

struct ClockEventLine: Shape {
    
    enum EventType {
        case morning
        case evening
        case both
    }
    
    // Minute is 0.5 Degrees
    // Hour is 30 Degrees
    let start: Date?
    let end: Date?
    let startComponents: DateComponents?
    let endComponents: DateComponents?
    let radius: CGFloat
    let width: Double
    var startDegrees: Double = 0.0
    var endDegrees: Double = 0.0
    
    init(start: Double, end: Double, radius: Double, width: Double) {
        self.startDegrees = start
        self.endDegrees = end
        self.radius = radius
        self.width = width
        self.start = nil
        self.end = nil
        self.startComponents = nil
        self.endComponents = nil
    }
    
    init(start: Date, end: Date, radius: Double, width: Double) {
        self.start = start
        self.end = end
        self.startComponents = nil
        self.endComponents = nil
        self.radius = radius
        self.width = width
        self.startDegrees = self.getAngle(for: start)
        self.endDegrees = self.getAngle(for: end)
    }
    init(startComponents: DateComponents?, endComponents: DateComponents?, radius: Double, width: Double) {
        self.startComponents = startComponents ?? DateComponents()
        self.endComponents = endComponents ?? DateComponents()
        self.start = nil
        self.end = nil
        self.radius = radius
        self.width = width
        self.startDegrees = self.getAngle(with: startComponents)
        self.endDegrees = self.getAngle(with: endComponents)
    }
    
    func getType() -> EventType {
        if startComponents?.hour ?? 13 <= 12 || start?.get(.hour) ?? 13 <= 12 {
            if endComponents?.hour ?? 0 >= 12 || end?.get(.hour) ?? 0 >= 12 {
                return .both
            } else {
                return .morning
            }
        } else {
            return .evening
        }
    }
    
    func getAngle(for date: Date? = nil, with components: DateComponents? = nil) -> Double {
        if let date = date {
            let hour = date.get(.hour)
            let trueHour = hour > 12 ? hour - 12 : hour
            return Double(trueHour * 30) + Double(date.get(.minute)) * 0.5 - 90
        } else if let hour = components?.hour,
                  let min = components?.minute {
            let trueHour = hour > 12 ? hour - 12 : hour
            return Double(trueHour) * 30.0 + Double(min) * 0.5 - 90
        } else {
            return 0.0
        }
    }
    /// Returns a point on a circle in the bearing for the given degrees
    func getPoint(radius: CGFloat, in rect: CGRect, for bearing: CGFloat) -> CGPoint {
        let x = rect.midX + radius * cos(bearing)
        let y = rect.midY + radius * sin(bearing)
        return CGPoint(x: x, y: y)
    }
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        let amRadius = self.radius * 0.85
        let pmRadius = self.radius * 1.15
        switch self.getType() {
        case .morning:
            path.addArc(center: center, radius: amRadius, startAngle: .degrees(self.startDegrees), endAngle: .degrees(self.endDegrees), clockwise: false)
        case.evening:
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: pmRadius, startAngle: .degrees(self.startDegrees), endAngle: .degrees(self.endDegrees), clockwise: false)
        case .both:
            // morning
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: amRadius, startAngle: .degrees(self.startDegrees), endAngle: .degrees(-110), clockwise: false)
            // noon crossover
            let control1 = CGPoint(x: rect.maxX * 0.6, y: rect.maxY * 0.05)
            let control2 = CGPoint(x: rect.maxX * 0.4, y: 0 - rect.maxY * 0.03)
            path.addCurve(to: self.getPoint(radius: pmRadius, in: rect, for: (360-80).radians()), control1: control1, control2: control2)
            // evening
            print(self.endDegrees)
            print(max(360-80, self.endDegrees))
            print(Angle.degrees(-80))
            print(Angle.degrees(self.endDegrees))
//            if self.endDegrees != 360-80 {
                path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: pmRadius, startAngle: .degrees(360-80), endAngle: .degrees(self.endDegrees), clockwise: false)
//            }
        }
        let lineDashes: [CGFloat] = (self.start == nil && self.startComponents == nil) ? [10, 5] : []
        return path.strokedPath(.init(lineWidth: self.width, lineCap: .square, lineJoin: .miter, dash: lineDashes))
    }
}

extension Double {
    func radians() -> Double {
        return self * .pi / 180
    }
}
