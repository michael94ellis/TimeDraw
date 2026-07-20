//
//  DateFormatter+Extensions.swift
//  EventUIComponents
//
//  Created by Michael Ellis on 7/20/26.
//

import Foundation

public extension DateFormatter {
    convenience init(format: String) {
        self.init()
        self.dateFormat = format
    }
    convenience init(dateFormat: String, calendar: Calendar) {
        self.init()
        self.dateFormat = dateFormat
        self.calendar = calendar
    }
    static let monthFormatter: DateFormatter = .init(dateFormat: "MMMM", calendar: Calendar.current)
    static let dayFormatter: DateFormatter = .init(dateFormat: "d", calendar: Calendar.current)
    static let weekDayFormatter: DateFormatter = .init(dateFormat: "EEE", calendar: Calendar.current)
    static let fullFormatter: DateFormatter = .init(dateFormat: "MMMM dd, yyyy", calendar: Calendar.current)
    static let timeFormatter: DateFormatter = .init(dateFormat: "M/d, hh:mm a", calendar: Calendar.current)
    static let weekdayLetterFormatter: DateFormatter = .init(dateFormat: "E", calendar: Calendar.current)
    static let eventTimeOnlyFormatter: DateFormatter = .init(dateFormat: "h:mma", calendar: Calendar.current)
    static let eventTimeRangeFormatter: DateFormatter = .init(dateFormat: "h:mm a", calendar: Calendar.current)
    static let eventDateShortFormatter: DateFormatter = .init(dateFormat: "MMM d, yyyy", calendar: Calendar.current)
    static let reminderTimeOnlyFormatter: DateFormatter = .init(dateFormat: "h:mm a", calendar: Calendar.current)
    static let inputDateTimeFormatter: DateFormatter = .init(dateFormat: "MMM d, h:mm a", calendar: Calendar.current)
}
