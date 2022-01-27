//
//  DateAndTimePickers.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/26/22.
//

import SwiftUI

struct DateAndTimePickers: View {
    
    public var suggestTimeInterval: Int?
    
    @Binding public var dateTime: Date?
    
    var suggestedDate: Date? {
        if self.dateTime == nil {
            guard let suggestTimeInterval = suggestTimeInterval else {
                return Date()
            }
            return Date().addingTimeInterval(TimeInterval(suggestTimeInterval))
        }
        return self.dateTime
    }
    
    public var dateSuggestBinding: Binding<Date?> { Binding<Date?>(
        get: { self.suggestedDate }, set: {
            if let newDate = $0, let unwrappedDate = self.dateTime {
                let timeComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: unwrappedDate)
                let combinedComponents = Calendar.current.date(bySettingHour: timeComponents.hour ?? 0, minute: timeComponents.minute ?? 0, second: timeComponents.second ?? 0, of: newDate)
                self.dateTime = combinedComponents
            } else {
                self.dateTime = $0
            }
        })
    }
    public var timeSuggestBinding: Binding<Date?> { Binding<Date?>(
        get: { self.suggestedDate },
        set: {
            if let newTime = $0, let unwrappedTime = self.dateTime {
                let newComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: newTime)
                let timeComponents = Calendar.current.date(bySettingHour: newComponents.hour ?? 0, minute: newComponents.minute ?? 0, second: newComponents.second ?? 0, of: unwrappedTime)
                self.dateTime = timeComponents
            } else {
                self.dateTime = $0
            }
        })
    }
    
    var body: some View {
        DateTimePickerInputView(date: self.dateSuggestBinding, placeholder: "Date", mode: .date, format: "MMM dd, yyyy")
            .background(RoundedRectangle(cornerRadius: 4)
                            .fill(Color(uiColor: .systemGray5)))
            .frame(maxWidth: 200)
            .frame(height: 30)
        DateTimePickerInputView(date: self.timeSuggestBinding, placeholder: "Time", mode: .time, format: "hh:mm a")
            .frame(maxWidth: 200)
            .frame(height: 30)
            .background(RoundedRectangle(cornerRadius: 4)
                            .fill(Color(uiColor: .systemGray5)))
    }
}
