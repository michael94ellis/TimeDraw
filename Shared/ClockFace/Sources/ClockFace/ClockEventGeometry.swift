//
//  ClockEventGeometry.swift
//  TimeDraw
//

import EventKit
import SwiftUI

enum ClockEventType {
    case morning
    case evening
    case both
}

public enum ClockRing: Sendable {
    case am
    case pm
}

enum ClockEventGeometry {
    static let noonDegrees = 270.0
    static let bendHalf = 8.0
    static let amRadiusMultiplier: CGFloat = 0.8
    static let pmRadiusMultiplier: CGFloat = 1.04
    static let crossoverSteps = 24
    static let reminderDuration: TimeInterval = 5 * 60

  /// Minutes on each side of noon covered by the crossover bend (8° × 2 min/°).
    static var bendMinutes: TimeInterval { bendHalf * 2.0 * 60 }

    static func eventType(startHour: Int, endHour: Int) -> ClockEventType {
        if startHour < 12 {
            if endHour >= 12 { return .both }
            return .morning
        }
        return .evening
    }

    static func eventType(start: Date, end: Date, calendar: Calendar = .current) -> ClockEventType {
        let noonDate = noon(on: start, calendar: calendar)
        if start < noonDate {
            if end > noonDate { return .both }
            return .morning
        }
        return .evening
    }

    static func angle(for date: Date, calendar: Calendar = .current) -> Double {
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let trueHour = hour > 12 ? hour - 12 : hour
        return Double(trueHour * 30) + Double(minute) * 0.5 - 90
    }

    static func angle(for components: DateComponents, calendar: Calendar = .current) -> Double {
        guard let hour = components.hour, let minute = components.minute else { return 0 }
        let trueHour = hour > 12 ? hour - 12 : hour
        return Double(trueHour) * 30.0 + Double(minute) * 0.5 - 90
    }

    static func normalizedEndAngle(startDegrees: Double, endDegrees: Double) -> Double {
        var normalized = endDegrees
        if normalized < startDegrees { normalized += 360 }
        return normalized
    }

    static func bendRange(startDegrees: Double, endDegrees: Double) -> (bendStart: Double, bendEnd: Double) {
        let normalizedEnd = normalizedEndAngle(startDegrees: startDegrees, endDegrees: endDegrees)
        let bendStart = max(startDegrees, noonDegrees - bendHalf)
        let bendEnd = min(normalizedEnd, noonDegrees + bendHalf)
        return (bendStart, bendEnd)
    }

    static func noon(on day: Date, calendar: Calendar = .current) -> Date {
        let start = calendar.startOfDay(for: day)
        return calendar.date(byAdding: .hour, value: 12, to: start) ?? start
    }

    static func crossoverWindow(on day: Date, calendar: Calendar = .current) -> (start: Date, end: Date) {
        let noonDate = noon(on: day, calendar: calendar)
        return (
            noonDate.addingTimeInterval(-bendMinutes),
            noonDate.addingTimeInterval(bendMinutes)
        )
    }

    static func amArcTimeRange(for item: ClockDrawableItem, noon: Date, calendar: Calendar = .current) -> (Date, Date)? {
        switch item.eventType {
        case .morning:
            guard item.startDate < item.endDate else { return nil }
            return (item.startDate, item.endDate)
        case .both:
            let window = crossoverWindow(on: noon, calendar: calendar)
            let end = min(item.endDate, noon, window.start)
            guard item.startDate < end else { return nil }
            return (item.startDate, end)
        case .evening:
            return nil
        }
    }

    static func pmArcTimeRange(for item: ClockDrawableItem, noon: Date, calendar: Calendar = .current) -> (Date, Date)? {
        switch item.eventType {
        case .evening:
            guard item.startDate < item.endDate else { return nil }
            return (item.startDate, item.endDate)
        case .both:
            let window = crossoverWindow(on: noon, calendar: calendar)
            let start = max(item.startDate, noon, window.end)
            guard start < item.endDate else { return nil }
            return (start, item.endDate)
        case .morning:
            return nil
        }
    }

    static func crossoverTimeRange(for item: ClockDrawableItem, noon: Date, calendar: Calendar = .current) -> (Date, Date)? {
        guard item.eventType == .both else { return nil }
        let window = crossoverWindow(on: noon, calendar: calendar)
        let start = max(item.startDate, window.start)
        let end = min(item.endDate, window.end)
        guard start < end else { return nil }
        return (start, end)
    }

    static func intersectsInterval(itemStart: Date, itemEnd: Date, intervalStart: Date, intervalEnd: Date) -> Bool {
        itemStart < intervalEnd && itemEnd > intervalStart
    }

    static func clipRange(
        _ range: (Date, Date),
        toIntervalStart intervalStart: Date,
        intervalEnd: Date
    ) -> (Date, Date)? {
        let start = max(range.0, intervalStart)
        let end = min(range.1, intervalEnd)
        guard start < end else { return nil }
        return (start, end)
    }

    static func point(radius: CGFloat, in rect: CGRect, degrees: Double) -> CGPoint {
        let bearing = CGFloat(degrees * .pi / 180)
        return CGPoint(
            x: rect.midX + radius * cos(bearing),
            y: rect.midY + radius * sin(bearing)
        )
    }

    static func smoothstep(_ value: Double) -> Double {
        let clamped = min(max(value, 0), 1)
        return clamped * clamped * (3 - 2 * clamped)
    }
}

public struct ClockDrawableItem: Identifiable, Hashable {
    enum Kind: Hashable {
        case event
        case reminder
    }

    public let id: String
    let kind: Kind
    let startDate: Date
    let endDate: Date
    let color: Color
    let isAllDay: Bool
    let eventType: ClockEventType
    private let event: EKEvent?
    private let reminder: EKReminder?

    var calendarItem: EKCalendarItem {
        if let event { return event }
        return reminder!
    }

    public static func from(events: [EKEvent], reminders: [EKReminder]) -> [ClockDrawableItem] {
        var items: [ClockDrawableItem] = []
        items.reserveCapacity(events.count + reminders.count)

        for event in events where !event.isAllDay {
            items.append(ClockDrawableItem(event: event))
        }
        for reminder in reminders {
            if let item = ClockDrawableItem(reminder: reminder) {
                items.append(item)
            }
        }
        return items
    }

    public static func allDayEvents(from events: [EKEvent]) -> [EKEvent] {
        events.filter(\.isAllDay)
    }

    private init(event: EKEvent) {
        id = event.eventIdentifier ?? UUID().uuidString
        kind = .event
        startDate = event.startDate
        endDate = event.endDate
        color = Color(cgColor: event.calendar?.cgColor ?? UIColor.clear.cgColor)
        isAllDay = false
        eventType = ClockEventGeometry.eventType(start: event.startDate, end: event.endDate)
        self.event = event
        reminder = nil
    }

    private init?(reminder: EKReminder) {
        guard let interval = Self.reminderInterval(for: reminder) else { return nil }
        id = reminder.calendarItemIdentifier
        kind = .reminder
        startDate = interval.start
        endDate = interval.end
        color = Color(cgColor: reminder.calendar?.cgColor ?? UIColor.clear.cgColor)
        isAllDay = false
        eventType = ClockEventGeometry.eventType(start: interval.start, end: interval.end)
        event = nil
        self.reminder = reminder
    }

    static func reminderInterval(for reminder: EKReminder, calendar: Calendar = .current) -> (start: Date, end: Date)? {
        if let start = timedDate(from: reminder.startDateComponents, calendar: calendar) {
            return (start, start.addingTimeInterval(ClockEventGeometry.reminderDuration))
        }
        if let due = timedDate(from: reminder.dueDateComponents, calendar: calendar) {
            return (due.addingTimeInterval(-ClockEventGeometry.reminderDuration), due)
        }
        return nil
    }

    private static func timedDate(from components: DateComponents?, calendar: Calendar) -> Date? {
        guard let components else { return nil }
        guard components.hour != nil || components.minute != nil else { return nil }
        return calendar.date(from: components)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: ClockDrawableItem, rhs: ClockDrawableItem) -> Bool {
        lhs.id == rhs.id
    }
}
