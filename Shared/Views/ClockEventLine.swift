//
//  ClockEventLine.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/16/22.
//

import SwiftUI

struct ClockEventLine: Shape {
    enum SegmentMode {
        case fullEvent
        case arc(ring: ClockRing, startDegrees: Double, endDegrees: Double)
    }

    let startComponents: DateComponents?
    let endComponents: DateComponents?
    let radius: CGFloat
    let width: Double
    let radiusOffset: CGFloat
    let segmentMode: SegmentMode
    var startDegrees: Double = 0.0
    var endDegrees: Double = 0.0

    init(start: Double, end: Double, radius: Double, width: Double) {
        self.startDegrees = start
        self.endDegrees = end
        self.radius = radius
        self.width = width
        self.radiusOffset = 0
        self.segmentMode = .fullEvent
        self.startComponents = nil
        self.endComponents = nil
    }

    init(start: Date, end: Date, radius: Double, width: Double) {
        self.startComponents = Calendar.current.dateComponents([.hour, .minute], from: start)
        self.endComponents = Calendar.current.dateComponents([.hour, .minute], from: end)
        self.radius = radius
        self.width = width
        self.radiusOffset = 0
        self.segmentMode = .fullEvent
        self.startDegrees = ClockEventGeometry.angle(for: start)
        self.endDegrees = ClockEventGeometry.angle(for: end)
    }

    init(startComponents: DateComponents,
         endComponents: DateComponents,
         radius: Double,
         width: Double) {
        self.startComponents = startComponents
        self.endComponents = endComponents
        self.radius = radius
        self.width = width
        self.radiusOffset = 0
        self.segmentMode = .fullEvent
        self.startDegrees = ClockEventGeometry.angle(for: startComponents)
        self.endDegrees = ClockEventGeometry.angle(for: endComponents)
    }

    init(
        arcRing: ClockRing,
        startDegrees: Double,
        endDegrees: Double,
        radius: Double,
        width: Double,
        radiusOffset: CGFloat = 0
    ) {
        self.startComponents = nil
        self.endComponents = nil
        self.radius = radius
        self.width = width
        self.radiusOffset = radiusOffset
        self.segmentMode = .arc(ring: arcRing, startDegrees: startDegrees, endDegrees: endDegrees)
        self.startDegrees = startDegrees
        self.endDegrees = endDegrees
    }

    private var eventType: ClockEventType? {
        switch segmentMode {
        case .fullEvent:
            guard let start = startComponents?.hour, let end = endComponents?.hour else { return nil }
            return ClockEventGeometry.eventType(startHour: start, endHour: end)
        case .arc(let ring, _, _):
            switch ring {
            case .am: return .morning
            case .pm: return .evening
            }
        }
    }

    func path(in rect: CGRect) -> Path {
        switch segmentMode {
        case .arc:
            return centerlinePath(in: rect)
        case .fullEvent:
            return centerlinePath(in: rect)
                .strokedPath(.init(lineWidth: self.width, lineCap: .round, lineJoin: .round, dash: dashPattern))
        }
    }

    private var dashPattern: [CGFloat] {
        switch segmentMode {
        case .fullEvent:
            switch eventType {
            case .morning, .evening, .both:
                return []
            default:
                return [10, 5]
            }
        case .arc:
            return []
        }
    }

    private func centerlinePath(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        let baseRadius = self.radius + radiusOffset
        let amRadius = baseRadius * ClockEventGeometry.amRadiusMultiplier
        let pmRadius = baseRadius * ClockEventGeometry.pmRadiusMultiplier

        switch segmentMode {
        case .arc(let ring, let start, let end):
            addArc(to: &path, ring: ring, center: center, amRadius: amRadius, pmRadius: pmRadius, start: start, end: end)
        case .fullEvent:
            switch self.eventType {
            case .morning:
                addArc(to: &path, ring: .am, center: center, amRadius: amRadius, pmRadius: pmRadius, start: self.startDegrees, end: self.endDegrees)
            case .evening:
                addArc(to: &path, ring: .pm, center: center, amRadius: amRadius, pmRadius: pmRadius, start: self.startDegrees, end: self.endDegrees)
            case .both:
                ClockCrossoverBend.addNoonCrossover(
                    to: &path,
                    in: rect,
                    center: center,
                    amRadius: amRadius,
                    pmRadius: pmRadius,
                    startDegrees: self.startDegrees,
                    endDegrees: self.endDegrees
                )
            default:
                break
            }
        }

        return path
    }

    private func addArc(
        to path: inout Path,
        ring: ClockRing,
        center: CGPoint,
        amRadius: CGFloat,
        pmRadius: CGFloat,
        start: Double,
        end: Double
    ) {
        let drawEnd = end < start
            ? ClockEventGeometry.normalizedEndAngle(startDegrees: start, endDegrees: end)
            : end
        let arcRadius = ring == .am ? amRadius : pmRadius
        path.addArc(
            center: center,
            radius: arcRadius,
            startAngle: .degrees(start),
            endAngle: .degrees(drawEnd),
            clockwise: false
        )
    }
}

struct ClockCrossoverBend: Shape {
    let startDegrees: Double
    let endDegrees: Double
    let radius: CGFloat
    let width: Double

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let amRadius = radius * ClockEventGeometry.amRadiusMultiplier
        let pmRadius = radius * ClockEventGeometry.pmRadiusMultiplier
        var path = Path()
        Self.addBendSweep(
            to: &path,
            in: rect,
            center: center,
            amRadius: amRadius,
            pmRadius: pmRadius,
            startDegrees: startDegrees,
            endDegrees: endDegrees
        )
        return path.strokedPath(.init(lineWidth: width, lineCap: .round, lineJoin: .round))
    }

    static func addNoonCrossover(
        to path: inout Path,
        in rect: CGRect,
        center: CGPoint,
        amRadius: CGFloat,
        pmRadius: CGFloat,
        startDegrees: Double,
        endDegrees: Double
    ) {
        let normalizedEnd = ClockEventGeometry.normalizedEndAngle(startDegrees: startDegrees, endDegrees: endDegrees)
        let (bendStart, bendEnd) = ClockEventGeometry.bendRange(startDegrees: startDegrees, endDegrees: endDegrees)

        if bendStart >= bendEnd {
            addBendSweep(
                to: &path,
                in: rect,
                center: center,
                amRadius: amRadius,
                pmRadius: pmRadius,
                startDegrees: startDegrees,
                endDegrees: normalizedEnd
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

        addBendSweep(
            to: &path,
            in: rect,
            center: center,
            amRadius: amRadius,
            pmRadius: pmRadius,
            startDegrees: bendStart,
            endDegrees: bendEnd,
            moveToStart: startDegrees >= bendStart
        )

        if bendEnd < normalizedEnd {
            let pmEnd = endDegrees < bendEnd
                ? ClockEventGeometry.normalizedEndAngle(startDegrees: bendEnd, endDegrees: endDegrees)
                : endDegrees
            path.addArc(
                center: center,
                radius: pmRadius,
                startAngle: .degrees(bendEnd),
                endAngle: .degrees(pmEnd),
                clockwise: false
            )
        }
    }

    static func addBendSweep(
        to path: inout Path,
        in rect: CGRect,
        center: CGPoint,
        amRadius: CGFloat,
        pmRadius: CGFloat,
        startDegrees: Double,
        endDegrees: Double,
        moveToStart: Bool = true
    ) {
        guard endDegrees > startDegrees else { return }
        let steps = ClockEventGeometry.crossoverSteps

        for i in 0...steps {
            let t = Double(i) / Double(steps)
            let angle = startDegrees + (endDegrees - startDegrees) * t
            let eased = ClockEventGeometry.smoothstep(t)
            let r = amRadius + (pmRadius - amRadius) * CGFloat(eased)
            let point = ClockEventGeometry.point(radius: r, in: rect, degrees: angle)
            if i == 0 && moveToStart {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
    }
}
