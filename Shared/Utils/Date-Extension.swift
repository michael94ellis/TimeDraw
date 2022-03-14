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
