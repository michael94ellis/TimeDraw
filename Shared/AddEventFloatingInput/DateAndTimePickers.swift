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
        guard self.dateTime != nil else {
            guard let suggestTimeInterval = suggestTimeInterval else {
                return nil
            }
            return Date().addingTimeInterval(TimeInterval(suggestTimeInterval))
        }
        return self.dateTime
    }
    
    public var endDateSuggestBinding: Binding<Date?> { Binding<Date?>(
        get: { return self.suggestedDate },
        set: {
            if let newDate = $0, let unwrappedDate = self.dateTime {
                let newComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: newDate)
                let dateComponents = Calendar.current.date(bySettingHour: newComponents.hour ?? 0, minute: newComponents.minute ?? 0, second: newComponents.second ?? 0, of: unwrappedDate)
                self.dateTime = dateComponents
            }
        })
    }
    public var endTimeSuggestBinding: Binding<Date?> { Binding<Date?>(
        get: { return self.suggestedDate },
        set: {
            if let newTime = $0, let unwrappedTime = self.dateTime {
                let newComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: newTime)
                let timeComponents = Calendar.current.date(bySettingHour: newComponents.hour ?? 0, minute: newComponents.minute ?? 0, second: newComponents.second ?? 0, of: unwrappedTime)
                self.dateTime = timeComponents
            }
        })
    }
    
    var body: some View {
        DateTimePickerInputView(date: self.endDateSuggestBinding, placeholder: "Date", mode: .date, format: "MMM dd, yy")
            .frame(maxWidth: 200)
            .frame(height: 30)
            .background(RoundedRectangle(cornerRadius: 4)
                            .fill(Color(uiColor: .systemGray5)))
        DateTimePickerInputView(date: self.endTimeSuggestBinding, placeholder: "Time", mode: .time, format: "hh:mm a")
            .frame(maxWidth: 200)
            .frame(height: 30)
            .background(RoundedRectangle(cornerRadius: 4)
                            .fill(Color(uiColor: .systemGray5)))
    }
}
