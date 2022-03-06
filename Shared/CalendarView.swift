//
//  CalendarView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/5/22.
//

import SwiftUI

struct CalendarDateSelection: View {
    private let calendar: Calendar
    private let monthFormatter: DateFormatter
    private let dayFormatter: DateFormatter
    private let weekDayFormatter: DateFormatter
    private let fullFormatter: DateFormatter

    @Binding private var selectedDate: Date

    init(calendar: Calendar, date: Binding<Date>) {
        self._selectedDate = date
        self.calendar = calendar
        self.monthFormatter = DateFormatter(dateFormat: "MMMM", calendar: calendar)
        self.dayFormatter = DateFormatter(dateFormat: "d", calendar: calendar)
        self.weekDayFormatter = DateFormatter(dateFormat: "EEE", calendar: calendar)
        self.fullFormatter = DateFormatter(dateFormat: "MMMM dd, yyyy", calendar: calendar)
    }

    var body: some View {
        VStack {
            CalendarView(
                calendar: calendar,
                date: $selectedDate,
                content: { date in
                    Button(action: { selectedDate = date }) {
                        Text("00")
                            .padding(10)
                            .foregroundColor(.clear)
                            .background(
                                self.calendar.isDate(date, inSameDayAs: selectedDate) ? Color(uiColor: .systemGray2)
                                : calendar.isDateInToday(date) ? Color(uiColor: .systemGray4)
                                : Color(uiColor: .systemGray6)
                            )
                            .frame(width: 36, height: 36)
                            .cornerRadius(8)
                            .accessibilityHidden(true)
                            .overlay(
                                Text(dayFormatter.string(from: date))
                                    .foregroundColor(
                                        self.calendar.isDate(date, inSameDayAs: selectedDate) ? Color.white
                                        : calendar.isDateInToday(date) ? Color(uiColor: .label)
                                        : Color(uiColor: .darkGray)))
                    }
                },
                excessDays: { date in
                    Button(action: { selectedDate = date }) {
                        Text(dayFormatter.string(from: date))
                            .foregroundColor(.secondary)
                            .frame(width: 45, height: 30)
                    }
                },
                header: { date in
                    Text(weekDayFormatter.string(from: date))
                        .frame(width: 45, height: 30)
                }
            )
            .equatable()
        }
    }
}

// MARK: - Component

public struct CalendarView<Day: View, Header: View, ExcessDay: View>: View {
    // Injected dependencies
    private var calendar: Calendar
    @Binding private var date: Date
    private let content: (Date) -> Day
    private let excessDays: (Date) -> ExcessDay
    private let header: (Date) -> Header

    // Constants
    private let daysInWeek = 7
    private var days: [Date] = []
    private let month: Date

    public init(
        calendar: Calendar,
        date: Binding<Date>,
        @ViewBuilder content: @escaping (Date) -> Day,
        @ViewBuilder excessDays: @escaping (Date) -> ExcessDay,
        @ViewBuilder header: @escaping (Date) -> Header
    ) {
        self.calendar = calendar
        self._date = date
        self.content = content
        self.excessDays = excessDays
        self.header = header
        
        self.month = date.wrappedValue.startOfMonth(using: calendar)
        self.days = self.makeDays()
    }
    
    public var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: self.daysInWeek)) {
            ForEach(days.prefix(self.daysInWeek), id: \.self, content: self.header)
            ForEach(days, id: \.self) { date in
                if self.calendar.isDate(date, equalTo: month, toGranularity: .month) {
                    self.content(date)
                } else {
                    self.excessDays(date)
                }
            }
        }
    }
}

// MARK: - Conformances

extension CalendarView: Equatable {
    public static func == (lhs: CalendarView<Day, Header, ExcessDay>, rhs: CalendarView<Day, Header, ExcessDay>) -> Bool {
        lhs.calendar == rhs.calendar && lhs.date == rhs.date
    }
}

// MARK: - Helpers

private extension CalendarView {
    func makeDays() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else {
            return []
        }

        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        return calendar.generateDays(for: dateInterval)
    }
}
