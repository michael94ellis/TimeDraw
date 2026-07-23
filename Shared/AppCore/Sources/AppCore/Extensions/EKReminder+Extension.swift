//
//  EKEvent+Extensions.swift
//  ClockFace
//
//  Created by Michael Ellis on 7/20/26.
//

import EventKit
import UIKit

extension EKReminder {
    public static func mock(startHour: Int?, endHour: Int?, color: UIColor) -> EKReminder {
        let store = EKEventStore()
        let reminder = EKReminder(eventStore: store)

        let calendar = EKCalendar(for: .reminder, eventStore: store)
        calendar.cgColor = color.cgColor
        reminder.calendar = calendar

        let today = Calendar.current.startOfDay(for: Date())
        if let startHour {
            reminder.startDateComponents = Calendar.current.dateComponents([.hour, .minute, .day, .month, .year], from: today.addingTimeInterval(TimeInterval(startHour * 3600)))
        }
        if let endHour {
            reminder.dueDateComponents = Calendar.current.dateComponents([.hour, .minute, .day, .month, .year], from: today.addingTimeInterval(TimeInterval(endHour * 3600)))
        }

        reminder.title = "Mock Reminder from \(startHour ?? -1)–\(endHour ?? -2)"

        return reminder
    }
}
