//
//  Date-Extension.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/4/22.
//

import Foundation

extension DateFormatter {
    convenience public init(format: String) {
        self.init()
        self.dateFormat = format
    }
    convenience init(dateFormat: String, calendar: Calendar) {
        self.init()
        self.dateFormat = dateFormat
        self.calendar = calendar
    }
    public static let monthFormatter: DateFormatter = .init(dateFormat: "MMMM", calendar: Calendar.current)
    public static let dayFormatter: DateFormatter = .init(dateFormat: "d", calendar: Calendar.current)
    public static let weekDayFormatter: DateFormatter = .init(dateFormat: "EEE", calendar: Calendar.current)
    public static let fullFormatter: DateFormatter = .init(dateFormat: "MMMM dd, yyyy", calendar: Calendar.current)
    public static let timeFormatter: DateFormatter = .init(dateFormat: "M/d, hh:mm a", calendar: Calendar.current)
    public static let weekdayLetterFormatter: DateFormatter = .init(dateFormat: "E", calendar: Calendar.current)
    public static let eventTimeOnlyFormatter: DateFormatter = .init(dateFormat: "h:mma", calendar: Calendar.current)
    public static let eventTimeRangeFormatter: DateFormatter = .init(dateFormat: "h:mm a", calendar: Calendar.current)
    public static let eventDateShortFormatter: DateFormatter = .init(dateFormat: "MMM d, yyyy", calendar: Calendar.current)
    public static let reminderTimeOnlyFormatter: DateFormatter = .init(dateFormat: "h:mm a", calendar: Calendar.current)
    public static let inputDateTimeFormatter: DateFormatter = .init(dateFormat: "MMM d, h:mm a", calendar: Calendar.current)
}

enum CalendarDisplayFormatters {

    static func eventTimeRange(from start: Date, to end: Date, isAllDay: Bool) -> String {
        if isAllDay { return "All Day" }
        let formatter = DateFormatter.eventTimeOnlyFormatter
        return "\(formatter.string(from: start)) – \(formatter.string(from: end))"
    }

    static func mergedDate(date: DateComponents?, time: DateComponents?) -> Date? {
        guard date != nil || time != nil else { return nil }
        var merged = DateComponents()
        merged.year = date?.year ?? time?.year
        merged.month = date?.month ?? time?.month
        merged.day = date?.day ?? time?.day
        merged.hour = time?.hour ?? date?.hour
        merged.minute = time?.minute ?? date?.minute
        merged.second = time?.second ?? date?.second
        return Calendar.current.date(from: merged)
    }

    static func inputDateTimeSummary(startDate: DateComponents?, startTime: DateComponents?,
                                     endDate: DateComponents?, endTime: DateComponents?) -> String? {
        guard let start = mergedDate(date: startDate, time: startTime) else { return nil }
        let formatter = DateFormatter.inputDateTimeFormatter
        if let end = mergedDate(date: endDate, time: endTime) {
            let sameDay = Calendar.current.isDate(start, inSameDayAs: end)
            if sameDay {
                return "\(formatter.string(from: start)) – \(DateFormatter.eventTimeRangeFormatter.string(from: end))"
            }
            return "\(formatter.string(from: start)) – \(formatter.string(from: end))"
        }
        return formatter.string(from: start)
    }

    static func reminderTimeRange(start: DateComponents?, due: DateComponents?) -> String? {
        let startText = start?.formattedReminderTime()
        let dueText = due?.formattedReminderTime()
        switch (startText, dueText) {
        case let (start?, due?) where start != due:
            return "\(start) – \(due)"
        case let (start?, nil):
            return start
        case let (nil, due?):
            return due
        case let (start?, due?) where start == due:
            return start
        default:
            return nil
        }
    }

    static func priorityLabel(for priority: Int) -> String? {
        switch priority {
        case 1...4: return "High"
        case 5: return "Medium"
        case 6...9: return "Low"
        default: return nil
        }
    }
}

extension DateComponents {

    func formattedReminderTime() -> String? {
        guard hour != nil || minute != nil else { return nil }
        var components = self
        if components.year == nil { components.year = 2000 }
        if components.month == nil { components.month = 1 }
        if components.day == nil { components.day = 1 }
        guard let date = Calendar.current.date(from: components) else { return nil }
        return DateFormatter.reminderTimeOnlyFormatter.string(from: date)
    }
}
extension Date {
    
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }
    
    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
    
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    func startOfMonth(using calendar: Calendar) -> Date {
        calendar.date(
            from: calendar.dateComponents([.year, .month], from: self)
        ) ?? self
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        // swiftlint:disable:next force_unwrapping
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
}
