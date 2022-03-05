//
//  DateAndTimePickers.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/26/22.
//

import SwiftUI

struct DateAndTimePickers: View {
    
    public var suggestTimeInterval: Int?
    
    @Binding public var dateTime: DateComponents?
    @Binding public var dateDate: DateComponents?
    
    public var dateSuggestBinding: Binding<Date?> { Binding<Date?>(
        get: {
            guard let date = self.dateDate else {
                guard let suggestTimeInterval = suggestTimeInterval else {
                    return nil
                }
                let suggestedDate = Date().addingTimeInterval(TimeInterval(suggestTimeInterval))
                return suggestedDate
            }
            return Calendar.current.date(from: date)
        }, set: {
            guard let newDate = $0 else {
                self.dateDate = nil
                return
            }
            self.dateDate = Calendar.current.dateComponents([.month, .day, .year], from: newDate)
        })
    }
    public var timeSuggestBinding: Binding<Date?> { Binding<Date?>(
        get: {
            guard let time = self.dateTime else {
                guard let suggestTimeInterval = suggestTimeInterval else {
                    return nil
                }
                let suggestedDate = Date().addingTimeInterval(TimeInterval(suggestTimeInterval))
                return suggestedDate
            }
            return Calendar.current.date(from: time)
        }, set: {
            guard let newTime = $0 else {
                self.dateTime = nil
                return
            }
            self.dateTime = Calendar.current.dateComponents([.hour, .minute, .second], from: newTime)
        })
    }
    
    var body: some View {
        DateTimePickerInputView(date: self.dateSuggestBinding, placeholder: "Date", mode: .date, format: "MMM dd, yyyy")
            .background(RoundedRectangle(cornerRadius: 4)
                            .fill(Color(uiColor: .systemGray5)))
            .frame(maxWidth: 200)
            .frame(height: 30)
            .onTapGesture {
                if self.dateDate == nil {
                    self.dateDate = Date().get(.year, .month, .day)
                }
            }
        DateTimePickerInputView(date: self.timeSuggestBinding, placeholder: "Time", mode: .time, format: "hh:mm a")
            .frame(maxWidth: 200)
            .frame(height: 30)
            .background(RoundedRectangle(cornerRadius: 4)
                            .fill(Color(uiColor: .systemGray5)))
            .onTapGesture {
                if self.dateDate == nil {
                    self.dateDate = Date().get(.year, .month, .day)
                }
                if self.dateTime == nil {
                    self.dateTime = Date().get(.hour, .minute, .second)
                }
            }
    }
}
