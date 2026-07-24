//
//  DateAndTimePickers.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/26/22.
//

import EventUIComponents
import AppCore
import SwiftUI

struct DateAndTimePickers: View {

    @Binding public var dateTime: DateComponents?
    @Binding public var dateDate: DateComponents?
    public var onTap: () -> Void

    private var combinedBinding: Binding<Date> {
        Binding(
            get: {
                CalendarDisplayFormatters.mergedDate(date: dateDate, time: dateTime) ?? Date()
            },
            set: { newValue in
                dateDate = Calendar.current.dateComponents([.year, .month, .day], from: newValue)
                dateTime = Calendar.current.dateComponents([.hour, .minute, .second], from: newValue)
            }
        )
    }

    var body: some View {
        DatePicker("End", selection: combinedBinding, displayedComponents: [.date, .hourAndMinute])
            .font(.app(.body))
            .onAppear(perform: onTap)
    }
}
