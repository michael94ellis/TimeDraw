//
//  CalendarView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/5/22.
//

import DesignToken
import AppCore
import SwiftUI

public struct CalendarView<Day: View, Header: View, ExcessDay: View>: View {
    // Injected dependencies
    @Binding private var date: Date
    private let content: (Date) -> Day
    private let excessDays: (Date) -> ExcessDay
    private let header: (Date) -> Header
    
    // Constants
    private let daysInWeek = 7
    private var days: [Date] = []
    private let month: Date
    private var weeks: [[Date]] = []
    
    public init(
        date: Binding<Date>,
        @ViewBuilder content: @escaping (Date) -> Day,
        @ViewBuilder excessDays: @escaping (Date) -> ExcessDay,
        @ViewBuilder header: @escaping (Date) -> Header
    ) {
        self._date = date
        self.content = content
        self.excessDays = excessDays
        self.header = header
        
        self.month = date.wrappedValue.startOfMonth(using: Calendar.current)
        let displayDates = self.makeDays()
        self.days = displayDates
        self.weeks = displayDates.chunked(into: 7)
    }
    
    public var body: some View {
        VStack {
            HStack {
                ForEach(self.days.prefix(self.daysInWeek), id: \.self, content: self.header)
                    .frame(width: 45)
            }
            ForEach(self.weeks, id: \.self) { week in
                HStack {
                    ForEach(week, id: \.self) { day in
                        if Calendar.current.isDate(day, equalTo: month, toGranularity: .month) {
                            self.content(day)
                                .frame(width: 45)
                        } else {
                            self.excessDays(day)
                                .frame(width: 45)
                        }
                    }
                }
            }
        }
    }
    
    func makeDays() -> [Date] {
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: self.date),
              let monthFirstWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else {
            return []
        }
        
        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        return Calendar.current.generateDays(for: dateInterval)
    }
}

extension CalendarView: Equatable {
    public static func == (lhs: CalendarView<Day, Header, ExcessDay>, rhs: CalendarView<Day, Header, ExcessDay>) -> Bool {
        lhs.date == rhs.date
    }
}
