//
//  EKWeekday-Extension.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/8/22.
//

import EventKit

extension EKWeekday: CaseIterable, CustomStringConvertible {
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
    public static func getSelectedWeekDays(for value: EKWeekday) -> [EKRecurrenceDayOfWeek] {
        return EKWeekday.allCases.compactMap {
            guard value == $0 else {
                return nil
            }
            return EKRecurrenceDayOfWeek($0)
        }
    }
}
