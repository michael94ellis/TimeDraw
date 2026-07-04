//
//  ClockAllDayLayoutEngine.swift
//  TimeDraw
//

import EventKit
import SwiftUI

struct ClockAllDaySegment: Identifiable {
    let id: String
    let color: Color
    let startDegrees: Double
    let endDegrees: Double
    let isFullCircle: Bool
    let dashPhase: CGFloat
}

enum ClockAllDayLayoutEngine {
    static let gapDegrees: Double = 2

    static func layout(events: [EKEvent]) -> [ClockAllDaySegment] {
        let sorted = events.sorted {
            ($0.title, $0.eventIdentifier ?? "") < ($1.title, $1.eventIdentifier ?? "")
        }
        let count = sorted.count
        guard count > 0 else { return [] }

        if count == 1, let event = sorted.first {
            return [segment(for: event, startDegrees: 0, endDegrees: 360, isFullCircle: true, index: 0)]
        }

        let slice = (360.0 - gapDegrees * Double(count)) / Double(count)
        return sorted.enumerated().map { index, event in
            let start = Double(index) * (slice + gapDegrees)
            return segment(
                for: event,
                startDegrees: start,
                endDegrees: start + slice,
                isFullCircle: false,
                index: index
            )
        }
    }

    private static func segment(
        for event: EKEvent,
        startDegrees: Double,
        endDegrees: Double,
        isFullCircle: Bool,
        index: Int
    ) -> ClockAllDaySegment {
        ClockAllDaySegment(
            id: event.eventIdentifier ?? UUID().uuidString,
            color: Color(cgColor: event.calendar?.cgColor ?? UIColor.clear.cgColor),
            startDegrees: startDegrees,
            endDegrees: endDegrees,
            isFullCircle: isFullCircle,
            dashPhase: CGFloat(index) * 3
        )
    }
}
