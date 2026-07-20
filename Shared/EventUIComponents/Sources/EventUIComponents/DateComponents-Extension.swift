//
//  DateComponents-Extension.swift
//  TimeDraw
//
//  Created by Michael Ellis on 6/13/25.
//

import Foundation

public extension DateComponents {
    /// Returns new DateComponents offset by a specified value for a given Calendar.Component
    func offset(by component: Calendar.Component, value: Int) -> DateComponents? {
        guard let date = Calendar.current.date(from: self),
              let newDate = Calendar.current.date(byAdding: component, value: value, to: date)
        else { return nil }

        return calendar?.dateComponents([.year, .month, .day, .hour, .minute, .second], from: newDate)
    }
    
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
