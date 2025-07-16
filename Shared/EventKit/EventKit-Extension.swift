//
//  EKWeekday-Extension.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/8/22.
//

import EventKit
import UIKit

extension EKWeekday: @retroactive CustomStringConvertible {
    public static var allCases: [EKWeekday] {
        return [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    }
    public var description: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
    public var shortDescription: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }
    public static func getSelectedWeekDays(for values: [EKWeekday]) -> [EKRecurrenceDayOfWeek] {
        return EKWeekday.allCases.compactMap {
            guard values.contains($0) else {
                return nil
            }
            return EKRecurrenceDayOfWeek($0)
        }
    }
}

extension EKCalendar {
    func archive() -> Data {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            return data
        } catch {
            fatalError("Can't encode data: \(error)")
        }
    }
}

extension Array {
    func archiveCalendars() -> Data {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            return data
        } catch {
            fatalError("Can't encode data: \(error)")
        }
    }
}
extension Optional where Wrapped == Data {
    func loadCalendarIds() -> [String] {
        do {
            guard let data = self,
                  let array = try NSKeyedUnarchiver.unarchivedObject(
                      ofClasses: [NSArray.self, NSString.self],
                      from: data
                  ) as? [String] else {
                return []
            }
            return array
        } catch {
            fatalError("loadWStringArray - Can't encode data: \(error)")
        }
    }
    func loadEKCalendar() -> EKCalendar? {
        do {
            guard let data = self else {
                return nil
            }
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
            unarchiver.requiresSecureCoding = false
            let calendar = unarchiver.decodeObject(forKey: NSKeyedArchiveRootObjectKey) as? EKCalendar
            return calendar
        } catch {
            fatalError("loadEKCalendar - Can't decode data: \(error)")
        }
    }
}

extension EKEvent {
    static func mock(startHour: Int, endHour: Int, color: UIColor) -> EKEvent {
        let store = EKEventStore()
        let event = EKEvent(eventStore: store)
        let today = Calendar.current.startOfDay(for: Date())
        event.startDate = today.addingTimeInterval(TimeInterval(startHour * 3600))
        event.endDate = today.addingTimeInterval(TimeInterval(endHour * 3600))
        let calendar = EKCalendar(for: .event, eventStore: store)
        calendar.cgColor = color.cgColor
        event.calendar = calendar
        return event
    }
}
extension EKReminder {
    static func mock(startHour: Int?, endHour: Int?, color: UIColor) -> EKReminder {
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
