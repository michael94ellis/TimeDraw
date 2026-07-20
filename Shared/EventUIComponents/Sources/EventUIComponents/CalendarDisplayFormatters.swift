//
//  CalendarDisplayFormatters.swift
//  EventUIComponents
//
//  Created by Michael Ellis on 7/20/26.
//

import Foundation

public enum CalendarDisplayFormatters {

    public static func eventTimeRange(from start: Date, to end: Date, isAllDay: Bool) -> String {
        if isAllDay { return "All Day" }
        let formatter = DateFormatter.eventTimeOnlyFormatter
        return "\(formatter.string(from: start)) – \(formatter.string(from: end))"
    }

    public static func mergedDate(date: DateComponents?, time: DateComponents?) -> Date? {
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

    public static func inputDateTimeSummary(startDate: DateComponents?, startTime: DateComponents?,
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

    public static func reminderTimeRange(start: DateComponents?, due: DateComponents?) -> String? {
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

    public static func priorityLabel(for priority: Int) -> String? {
        switch priority {
        case 1...4: return "High"
        case 5: return "Medium"
        case 6...9: return "Low"
        default: return nil
        }
    }
}
