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
                  let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String] else {
                return []
            }
            return array
        } catch {
            fatalError("loadWStringArray - Can't encode data: \(error)")
        }
    }
    func loadEKCalendar() -> EKCalendar? {
        do {
            guard let data = self,
                  let calendar = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? EKCalendar else {
                return nil
            }
            return calendar
        } catch {
            fatalError("loadWStringArray - Can't encode data: \(error)")
        }
    }
}
