//
//  CalendarView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/5/22.
//

import SwiftUI

struct CalendarDateSelection: View {
    
    @Binding private var selectedDate: Date
    @ObservedObject private var eventList: EventListViewModel = .shared

    init(date: Binding<Date>) {
        self._selectedDate = date
    }

    var body: some View {
        VStack {
            CalendarView(
                date: $selectedDate,
                content: { date in
                    Button(action: {
                        withAnimation {
                            selectedDate = date
                        }
                    }) {
                        let today = Calendar.current.isDateInToday(date)
                        let display = Calendar.current.isDate(date, inSameDayAs: self.eventList.displayDate)
                        Text("00")
                            .padding(10)
                            .foregroundColor(.clear)
                            .background(
                                Calendar.current.isDate(date, inSameDayAs: selectedDate) ? Color(uiColor: .systemGray2)
                                : Calendar.current.isDateInToday(date) ? Color(uiColor: .systemGray4)
                                : Color(uiColor: .systemGray6)
                            )
                            .frame(width: 36, height: 36)
                            .cornerRadius(8)
                            .accessibilityHidden(true)
                            .overlay(
                                Text(DateFormatter.dayFormatter.string(from: date)))
                            .if(today || display) { view in
                                view.font(.interBold)
                            }
                            .foregroundColor(
                                Calendar.current.isDate(date, inSameDayAs: selectedDate) ? Color.white
                                : Calendar.current.isDateInToday(date) ? Color(uiColor: .label)
                                : Color(uiColor: .darkGray))
                    }
                },
                excessDays: { date in
                    Button(action: {
                        withAnimation {
                            selectedDate = date
                        }
                    }) {
                        Text(DateFormatter.dayFormatter.string(from: date))
                            .foregroundColor(.secondary)
                            .frame(width: 45, height: 30)
                    }
                },
                header: { date in
                    Text(DateFormatter.weekDayFormatter.string(from: date))
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
    @Binding private var date: Date
    private let content: (Date) -> Day
    private let excessDays: (Date) -> ExcessDay
    private let header: (Date) -> Header

    // Constants
    private let daysInWeek = 7
    private var days: [Date] = []
    private let month: Date

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
        self.days = self.makeDays()
    }

    public var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(), count: self.daysInWeek)) {
            ForEach(self.days.prefix(self.daysInWeek), id: \.self, content: self.header)
            ForEach(self.days, id: \.self) { date in
                if Calendar.current.isDate(date, equalTo: month, toGranularity: .month) {
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
        lhs.date == rhs.date
    }
}

// MARK: - Helpers

private extension CalendarView {
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
