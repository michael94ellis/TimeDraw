//
//  Date-Extension.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/4/22.
//

import Foundation

extension Date {
    
    public func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }
    
    public func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
    
    public var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    public func startOfMonth(using calendar: Calendar) -> Date {
        calendar.date(
            from: calendar.dateComponents([.year, .month], from: self)
        ) ?? self
    }
    
    public var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        // swiftlint:disable:next force_unwrapping
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
}
