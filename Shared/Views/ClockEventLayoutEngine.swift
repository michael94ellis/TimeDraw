//
//  ClockEventLayoutEngine.swift
//  TimeDraw
//

import SwiftUI

struct ClockArcSegment: Identifiable {
    let id: String
    let item: ClockDrawableItem
    let ring: ClockRing
    let startDegrees: Double
    let endDegrees: Double
    let laneIndex: Int
    let laneCount: Int
    let lineWidth: CGFloat
    let radiusOffset: CGFloat

    var color: Color { item.color }
}

struct ClockCrossoverSegment: Identifiable {
    let id: String
    let item: ClockDrawableItem
    let startDegrees: Double
    let endDegrees: Double
    let laneIndex: Int
    let laneCount: Int
    let lineWidth: CGFloat
    let radiusOffset: CGFloat

    var color: Color { item.color }
}

struct ClockLayout {
    let arcSegments: [ClockArcSegment]
    let crossoverSegments: [ClockCrossoverSegment]
}

enum ClockEventLayoutEngine {

    static func layout(items: [ClockDrawableItem], clockWidth: CGFloat, calendar: Calendar = .current) -> ClockLayout {
        let timed = items.filter { !$0.isAllDay }
        guard !timed.isEmpty else {
            return ClockLayout(arcSegments: [], crossoverSegments: [])
        }

        let baseWidth = clockWidth / 24
        let noon = ClockEventGeometry.noon(on: timed[0].startDate, calendar: calendar)
        let breakpoints = buildBreakpoints(items: timed, noon: noon, calendar: calendar)

        var arcSegments: [ClockArcSegment] = []
        var crossoverSegments: [ClockCrossoverSegment] = []

        for index in 0..<(breakpoints.count - 1) {
            let intervalStart = breakpoints[index]
            let intervalEnd = breakpoints[index + 1]

            appendArcSegments(
                for: timed,
                ring: .am,
                intervalStart: intervalStart,
                intervalEnd: intervalEnd,
                noon: noon,
                baseWidth: baseWidth,
                segmentIndex: index,
                into: &arcSegments,
                calendar: calendar
            )

            appendArcSegments(
                for: timed,
                ring: .pm,
                intervalStart: intervalStart,
                intervalEnd: intervalEnd,
                noon: noon,
                baseWidth: baseWidth,
                segmentIndex: index,
                into: &arcSegments,
                calendar: calendar
            )

            appendCrossoverSegments(
                for: timed,
                intervalStart: intervalStart,
                intervalEnd: intervalEnd,
                noon: noon,
                baseWidth: baseWidth,
                segmentIndex: index,
                into: &crossoverSegments,
                calendar: calendar
            )
        }

        return ClockLayout(
            arcSegments: coalesceArcSegments(arcSegments),
            crossoverSegments: coalesceCrossoverSegments(crossoverSegments)
        )
    }

    private static func coalesceArcSegments(_ segments: [ClockArcSegment]) -> [ClockArcSegment] {
        guard !segments.isEmpty else { return [] }

        let sorted = segments.sorted {
            if $0.item.id != $1.item.id { return $0.item.id < $1.item.id }
            if $0.ring != $1.ring { return String(describing: $0.ring) < String(describing: $1.ring) }
            if $0.laneIndex != $1.laneIndex { return $0.laneIndex < $1.laneIndex }
            return $0.startDegrees < $1.startDegrees
        }

        var merged: [ClockArcSegment] = []
        for segment in sorted {
            if var last = merged.last,
               last.item.id == segment.item.id,
               last.ring == segment.ring,
               last.laneIndex == segment.laneIndex,
               last.laneCount == segment.laneCount,
               last.lineWidth == segment.lineWidth,
               last.radiusOffset == segment.radiusOffset,
               abs(last.endDegrees - segment.startDegrees) < 0.5 {
                last = ClockArcSegment(
                    id: last.id,
                    item: last.item,
                    ring: last.ring,
                    startDegrees: last.startDegrees,
                    endDegrees: segment.endDegrees,
                    laneIndex: last.laneIndex,
                    laneCount: last.laneCount,
                    lineWidth: last.lineWidth,
                    radiusOffset: last.radiusOffset
                )
                merged[merged.count - 1] = last
            } else {
                merged.append(segment)
            }
        }
        return merged
    }

    private static func coalesceCrossoverSegments(_ segments: [ClockCrossoverSegment]) -> [ClockCrossoverSegment] {
        guard !segments.isEmpty else { return [] }

        let sorted = segments.sorted {
            if $0.item.id != $1.item.id { return $0.item.id < $1.item.id }
            if $0.laneIndex != $1.laneIndex { return $0.laneIndex < $1.laneIndex }
            return $0.startDegrees < $1.startDegrees
        }

        var merged: [ClockCrossoverSegment] = []
        for segment in sorted {
            if var last = merged.last,
               last.item.id == segment.item.id,
               last.laneIndex == segment.laneIndex,
               last.laneCount == segment.laneCount,
               last.lineWidth == segment.lineWidth,
               last.radiusOffset == segment.radiusOffset,
               abs(last.endDegrees - segment.startDegrees) < 0.5 {
                last = ClockCrossoverSegment(
                    id: last.id,
                    item: last.item,
                    startDegrees: last.startDegrees,
                    endDegrees: segment.endDegrees,
                    laneIndex: last.laneIndex,
                    laneCount: last.laneCount,
                    lineWidth: last.lineWidth,
                    radiusOffset: last.radiusOffset
                )
                merged[merged.count - 1] = last
            } else {
                merged.append(segment)
            }
        }
        return merged
    }

    private static func buildBreakpoints(items: [ClockDrawableItem], noon: Date, calendar: Calendar) -> [Date] {
        var points = Set<Date>()
        for item in items {
            points.insert(item.startDate)
            points.insert(item.endDate)
        }

        let window = ClockEventGeometry.crossoverWindow(on: noon, calendar: calendar)
        if items.contains(where: { $0.eventType == .both }) {
            points.insert(noon)
            points.insert(window.start)
            points.insert(window.end)
        }

        return points.sorted()
    }

    private static func appendArcSegments(
        for items: [ClockDrawableItem],
        ring: ClockRing,
        intervalStart: Date,
        intervalEnd: Date,
        noon: Date,
        baseWidth: CGFloat,
        segmentIndex: Int,
        into arcSegments: inout [ClockArcSegment],
        calendar: Calendar
    ) {
        let active = items.filter { item in
            let range: (Date, Date)?
            switch ring {
            case .am: range = ClockEventGeometry.amArcTimeRange(for: item, noon: noon, calendar: calendar)
            case .pm: range = ClockEventGeometry.pmArcTimeRange(for: item, noon: noon, calendar: calendar)
            }
            guard let range else { return false }
            return ClockEventGeometry.intersectsInterval(
                itemStart: range.0,
                itemEnd: range.1,
                intervalStart: intervalStart,
                intervalEnd: intervalEnd
            )
        }
        .sorted { $0.startDate < $1.startDate }

        guard !active.isEmpty else { return }

        let laneCount = active.count
        let lineWidth = max(baseWidth / CGFloat(laneCount), 2)
        // Pack parallel lanes just wider than the stroke itself.
        let laneSpacing = lineWidth * 1.1
        let totalSpread = laneSpacing * CGFloat(max(laneCount - 1, 0))

        for (laneIndex, item) in active.enumerated() {
            let baseRange: (Date, Date)
            switch ring {
            case .am:
                baseRange = ClockEventGeometry.amArcTimeRange(for: item, noon: noon, calendar: calendar)!
            case .pm:
                baseRange = ClockEventGeometry.pmArcTimeRange(for: item, noon: noon, calendar: calendar)!
            }

            guard let clipped = ClockEventGeometry.clipRange(
                baseRange,
                toIntervalStart: intervalStart,
                intervalEnd: intervalEnd
            ) else { continue }

            let startDegrees = ClockEventGeometry.angle(for: clipped.0, calendar: calendar)
            let endDegrees = ClockEventGeometry.angle(for: clipped.1, calendar: calendar)
            let normalizedEnd = ClockEventGeometry.normalizedEndAngle(
                startDegrees: startDegrees,
                endDegrees: endDegrees
            )
            guard normalizedEnd > startDegrees else { continue }

            arcSegments.append(
                ClockArcSegment(
                    id: "\(item.id)-\(ring)-\(segmentIndex)-\(laneIndex)",
                    item: item,
                    ring: ring,
                    startDegrees: startDegrees,
                    endDegrees: endDegrees,
                    laneIndex: laneIndex,
                    laneCount: laneCount,
                    lineWidth: lineWidth,
                    radiusOffset: (CGFloat(laneIndex) * laneSpacing) - (totalSpread / 2)
                )
            )
        }
    }

    private static func appendCrossoverSegments(
        for items: [ClockDrawableItem],
        intervalStart: Date,
        intervalEnd: Date,
        noon: Date,
        baseWidth: CGFloat,
        segmentIndex: Int,
        into crossoverSegments: inout [ClockCrossoverSegment],
        calendar: Calendar
    ) {
        let active = items.filter { item in
            guard let range = ClockEventGeometry.crossoverTimeRange(for: item, noon: noon, calendar: calendar) else {
                return false
            }
            return ClockEventGeometry.intersectsInterval(
                itemStart: range.0,
                itemEnd: range.1,
                intervalStart: intervalStart,
                intervalEnd: intervalEnd
            )
        }
        .sorted { $0.startDate < $1.startDate }

        guard !active.isEmpty else { return }

        let laneCount = active.count
        let lineWidth = max(baseWidth / CGFloat(laneCount), 2)
        let laneSpacing = lineWidth * 1.1
        let totalSpread = laneSpacing * CGFloat(max(laneCount - 1, 0))

        for (laneIndex, item) in active.enumerated() {
            guard let range = ClockEventGeometry.crossoverTimeRange(for: item, noon: noon, calendar: calendar) else {
                continue
            }

            guard let clipped = ClockEventGeometry.clipRange(
                range,
                toIntervalStart: intervalStart,
                intervalEnd: intervalEnd
            ) else { continue }

            let startDegrees = ClockEventGeometry.angle(for: clipped.0, calendar: calendar)
            let endDegrees = ClockEventGeometry.angle(for: clipped.1, calendar: calendar)
            guard endDegrees > startDegrees else { continue }

            crossoverSegments.append(
                ClockCrossoverSegment(
                    id: "crossover-\(item.id)-\(segmentIndex)-\(laneIndex)",
                    item: item,
                    startDegrees: startDegrees,
                    endDegrees: endDegrees,
                    laneIndex: laneIndex,
                    laneCount: laneCount,
                    lineWidth: lineWidth,
                    radiusOffset: (CGFloat(laneIndex) * laneSpacing) - (totalSpread / 2)
                )
            )
        }
    }
}
