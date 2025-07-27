//
//  DateComponents-Extension.swift
//  TimeDraw
//
//  Created by Michael Ellis on 6/13/25.
//

import Foundation

extension DateComponents {
    /// Returns new DateComponents offset by a specified value for a given Calendar.Component
    func offset(by component: Calendar.Component, value: Int) -> DateComponents? {
        guard let date = Calendar.current.date(from: self),
              let newDate = Calendar.current.date(byAdding: component, value: value, to: date)
        else { return nil }

        return calendar?.dateComponents([.year, .month, .day, .hour, .minute, .second], from: newDate)
    }
}
