//
//  ClockEventLayoutEngine.swift
//  TimeDraw
//

import SwiftUI

public struct ClockArcSegment: Identifiable {
    public let id: String
    public let item: ClockDrawableItem
    public let ring: ClockRing
    public let startDegrees: Double
    public let endDegrees: Double
    public let laneIndex: Int
    public let laneCount: Int
    public let lineWidth: CGFloat
    public let radiusOffset: CGFloat

    public var color: Color { item.color }
}

/// Full AM→noon-bend→PM track for an event that crosses noon.
public struct ClockCrossoverSegment: Identifiable {
    public let id: String
    public let item: ClockDrawableItem
    public let startDegrees: Double
    public let endDegrees: Double
    public let laneIndex: Int
    public let laneCount: Int
    public let lineWidth: CGFloat
    public let radiusOffset: CGFloat

    public var color: Color { item.color }
}

public struct ClockLayout {
    public let arcSegments: [ClockArcSegment]
    public let crossoverSegments: [ClockCrossoverSegment]
}

public enum ClockEventLayoutEngine {

    private struct LaneMetrics {
        let laneIndex: Int
        let laneCount: Int
        let lineWidth: CGFloat
        let radiusOffset: CGFloat
    }

    public static func layout(items: [ClockDrawableItem],
                              clockWidth: CGFloat,
                              calendar: Calendar = .current) -> ClockLayout {
        let timed = items.filter { !$0.isAllDay }
        guard !timed.isEmpty else {
            return ClockLayout(arcSegments: [], crossoverSegments: [])
        }

        let baseWidth = clockWidth / 24
        let lanes = laneMetrics(for: timed, baseWidth: baseWidth)

        var arcSegments: [ClockArcSegment] = []
        var crossoverSegments: [ClockCrossoverSegment] = []

        for item in timed {
            guard let metrics = lanes[item.id] else { continue }

            switch item.eventType {
            case .morning:
                appendArcSegment(
                    for: item,
                    ring: .am,
                    metrics: metrics,
                    into: &arcSegments,
                    calendar: calendar
                )
            case .evening:
                appendArcSegment(
                    for: item,
                    ring: .pm,
                    metrics: metrics,
                    into: &arcSegments,
                    calendar: calendar
                )
            case .both:
                appendCrossingSegment(
                    for: item,
                    metrics: metrics,
                    into: &crossoverSegments,
                    calendar: calendar
                )
            }
        }

        return ClockLayout(arcSegments: arcSegments, crossoverSegments: crossoverSegments)
    }

    /// Greedy interval coloring so each event keeps one lane for its full duration.
    private static func laneMetrics(for items: [ClockDrawableItem],
                                    baseWidth: CGFloat) -> [String: LaneMetrics] {
        let sorted = items.sorted { lhs, rhs in
            if lhs.startDate != rhs.startDate { return lhs.startDate < rhs.startDate }
            if lhs.endDate != rhs.endDate { return lhs.endDate < rhs.endDate }
            return lhs.id < rhs.id
        }

        var active: [(end: Date, lane: Int)] = []
        var laneByID: [String: Int] = [:]
        var maxLane = -1

        for item in sorted {
            active.removeAll { $0.end <= item.startDate }
            let used = Set(active.map(\.lane))
            var lane = 0
            while used.contains(lane) { lane += 1 }
            laneByID[item.id] = lane
            active.append((item.endDate, lane))
            maxLane = max(maxLane, lane)
        }

        let laneCount = max(maxLane + 1, 1)
        let lineWidth = max(baseWidth / CGFloat(laneCount), 2)
        let laneSpacing = lineWidth * 1.1
        let totalSpread = laneSpacing * CGFloat(max(laneCount - 1, 0))

        var result: [String: LaneMetrics] = [:]
        result.reserveCapacity(items.count)
        for item in items {
            guard let laneIndex = laneByID[item.id] else { continue }
            result[item.id] = LaneMetrics(
                laneIndex: laneIndex,
                laneCount: laneCount,
                lineWidth: lineWidth,
                radiusOffset: CGFloat(laneIndex) * laneSpacing - totalSpread / 2
            )
        }
        return result
    }

    private static func appendArcSegment(
        for item: ClockDrawableItem,
        ring: ClockRing,
        metrics: LaneMetrics,
        into arcSegments: inout [ClockArcSegment],
        calendar: Calendar
    ) {
        guard item.startDate < item.endDate else { return }

        let startDegrees = ClockEventGeometry.angle(for: item.startDate, calendar: calendar)
        let endDegrees = ClockEventGeometry.angle(for: item.endDate, calendar: calendar)
        let normalizedEnd = ClockEventGeometry.normalizedEndAngle(
            startDegrees: startDegrees,
            endDegrees: endDegrees
        )
        guard normalizedEnd > startDegrees else { return }

        arcSegments.append(
            ClockArcSegment(
                id: "\(item.id)-\(ring)",
                item: item,
                ring: ring,
                startDegrees: startDegrees,
                endDegrees: endDegrees,
                laneIndex: metrics.laneIndex,
                laneCount: metrics.laneCount,
                lineWidth: metrics.lineWidth,
                radiusOffset: metrics.radiusOffset
            )
        )
    }

    private static func appendCrossingSegment(
        for item: ClockDrawableItem,
        metrics: LaneMetrics,
        into crossoverSegments: inout [ClockCrossoverSegment],
        calendar: Calendar
    ) {
        guard item.startDate < item.endDate else { return }

        let startDegrees = ClockEventGeometry.angle(for: item.startDate, calendar: calendar)
        let endDegrees = ClockEventGeometry.angle(for: item.endDate, calendar: calendar)
        let sweepEnd = ClockEventGeometry.crossingSweepEnd(
            startDegrees: startDegrees,
            endDegrees: endDegrees
        )
        guard sweepEnd > startDegrees else { return }

        crossoverSegments.append(
            ClockCrossoverSegment(
                id: "crossing-\(item.id)",
                item: item,
                startDegrees: startDegrees,
                endDegrees: endDegrees,
                laneIndex: metrics.laneIndex,
                laneCount: metrics.laneCount,
                lineWidth: metrics.lineWidth,
                radiusOffset: metrics.radiusOffset
            )
        )
    }
}
