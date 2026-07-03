//
//  ClockEventLine.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/16/22.
//

import SwiftUI

struct ClockEventLine: Shape {
    /// This signifies if the Event happens in the AM, PM ,or both
    enum EventType {
        case morning
        case evening
        case both
    }
    
    // Minute is 0.5 Degrees
    // Hour is 30 Degrees
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
        self.startComponents = nil
        self.endComponents = nil
    }
    
    init(start: Date, end: Date, radius: Double, width: Double) {
        self.startComponents = Calendar.current.dateComponents([.hour, .minute], from: start)
        self.endComponents = Calendar.current.dateComponents([.hour, .minute], from: end)
        self.radius = radius
        self.width = width
        self.startDegrees = self.getAngle(for: start)
        self.endDegrees = self.getAngle(for: end)
    }
    
    init(startComponents: DateComponents,
         endComponents: DateComponents,
         radius: Double,
         width: Double) {
        self.startComponents = startComponents
        self.endComponents = endComponents
        self.radius = radius
        self.width = width
        self.startDegrees = self.getAngle(with: startComponents)
        self.endDegrees = self.getAngle(with: endComponents)
    }
    
    /// Used to determine if this EventLine will be in AM, PM, or both
    func getType() -> EventType? {
        guard let start = startComponents?.hour, let end = endComponents?.hour else {
            return nil
        }
        if start < 12 {
            if end >= 12 {
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

    private func smoothstep(_ t: Double) -> Double {
        let clamped = min(max(t, 0), 1)
        return clamped * clamped * (3 - 2 * clamped)
    }

    private func addRadiusInterpolatedSweep(
        to path: inout Path,
        in rect: CGRect,
        from startAngle: Double,
        to endAngle: Double,
        amRadius: CGFloat,
        pmRadius: CGFloat,
        steps: Int,
        moveToStart: Bool
    ) {
        guard endAngle > startAngle else { return }

        for i in 0...steps {
            let t = Double(i) / Double(steps)
            let angle = startAngle + (endAngle - startAngle) * t
            let eased = smoothstep(t)
            let r = amRadius + (pmRadius - amRadius) * CGFloat(eased)
            let point = getPoint(radius: r, in: rect, for: CGFloat(angle * .pi / 180))
            if i == 0 && moveToStart {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
    }

    private func addNoonCrossover(
        to path: inout Path,
        in rect: CGRect,
        center: CGPoint,
        amRadius: CGFloat,
        pmRadius: CGFloat,
        startDegrees: Double,
        endDegrees: Double
    ) {
        let noon = 270.0
        let bendHalf = 8.0
        let steps = 24

        // PM times map to negative degrees (e.g. 1pm = -60°); unwrap for comparisons.
        var normalizedEndDegrees = endDegrees
        if normalizedEndDegrees < startDegrees {
            normalizedEndDegrees += 360
        }

        let bendStart = max(startDegrees, noon - bendHalf)
        let bendEnd = min(normalizedEndDegrees, noon + bendHalf)

        if bendStart >= bendEnd {
            addRadiusInterpolatedSweep(
                to: &path,
                in: rect,
                from: startDegrees,
                to: normalizedEndDegrees,
                amRadius: amRadius,
                pmRadius: pmRadius,
                steps: steps,
                moveToStart: true
            )
            return
        }

        if startDegrees < bendStart {
            path.addArc(
                center: center,
                radius: amRadius,
                startAngle: .degrees(startDegrees),
                endAngle: .degrees(bendStart),
                clockwise: false
            )
        }

        addRadiusInterpolatedSweep(
            to: &path,
            in: rect,
            from: bendStart,
            to: bendEnd,
            amRadius: amRadius,
            pmRadius: pmRadius,
            steps: steps,
            moveToStart: startDegrees >= bendStart
        )

        if bendEnd < normalizedEndDegrees {
            path.addArc(
                center: center,
                radius: pmRadius,
                startAngle: .degrees(bendEnd),
                endAngle: .degrees(endDegrees),
                clockwise: false
            )
        }
    }
    
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        /// Only for all day events
        var lineDashes: [CGFloat] = [10, 5]
        var path = Path()
        let amRadius = self.radius * 0.8
        let pmRadius = self.radius * 1.04
        switch self.getType() {
        case .morning:
            path.addArc(center: center, radius: amRadius, startAngle: .degrees(self.startDegrees), endAngle: .degrees(self.endDegrees), clockwise: false)
        case.evening:
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: pmRadius, startAngle: .degrees(self.startDegrees), endAngle: .degrees(self.endDegrees), clockwise: false)
        case .both:
            addNoonCrossover(
                to: &path,
                in: rect,
                center: center,
                amRadius: amRadius,
                pmRadius: pmRadius,
                startDegrees: self.startDegrees,
                endDegrees: self.endDegrees
            )
        default:
            lineDashes = [0, 0]
        }
        return path.strokedPath(.init(lineWidth: self.width, lineCap: .round, lineJoin: .round, dash: lineDashes))
    }
}
