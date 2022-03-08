//
//  MultiDateSelectCalendar.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/8/22.
//

import SwiftUI

struct CalendarMultiDateSelection: View {
    
    @Binding private var viewDate: Date
    @Binding private var selectedDates: [Date]
    @ObservedObject private var eventList: EventListViewModel = .shared
    
    init(viewDate: Binding<Date>, selectedDates: Binding<[Date]>) {
        self._viewDate = viewDate
        self._selectedDates = selectedDates
    }
    
    var body: some View {
        VStack {
            MultiSelectCalendarView(
                viewDate: self.$viewDate,
                selectedDates: self.$selectedDates,
                content: { date in
                    Button(action: {
                        var newDates: [Date] = []
                        if self.selectedDates.contains(date) {
                            newDates = self.selectedDates.filter({ $0 != date })
                        } else {
                            self.selectedDates.append(date)
                            newDates = self.selectedDates
                        }
                        
                        withAnimation {
                            self.selectedDates = newDates
                        }
                    }) {
                        let today = Calendar.current.isDateInToday(date)
                        let display = Calendar.current.isDate(date, inSameDayAs: self.eventList.displayDate)
                        Text("00")
                            .padding(10)
                            .foregroundColor(.clear)
                            .background(display ? Color(uiColor: .systemGray2)
                                        : today ? Color(uiColor: .systemGray4)
                                        : Color(uiColor: .systemGray6))
                            .frame(width: 36, height: 36)
                            .cornerRadius(8)
                            .accessibilityHidden(true)
                            .overlay(
                                Text(DateFormatter.dayFormatter.string(from: date)))
                            .if(today || display) { view in
                                view.font(.interBold)
                            }
                            .foregroundColor(today ? .red1
                                             : display ? .white
                                             : .gray2)
                    }
                },
                excessDays: { date in
                    Button(action: {
                        var newDates: [Date] = []
                        if self.selectedDates.contains(date) {
                            newDates = self.selectedDates.filter({ $0 != date })
                        } else {
                            self.selectedDates.append(date)
                            newDates = self.selectedDates
                        }
                        
                        withAnimation {
                            self.selectedDates = newDates
                        }
                    }) {
                        Text(DateFormatter.dayFormatter.string(from: date))
                            .foregroundColor(.secondary)
                            .frame(width: 45, height: 30)
                    }
                },
                header: { date in
                    Text(DateFormatter.weekDayFormatter.string(from: date))
                        .font(.interLight)
                        .frame(width: 45, height: 30)
                }
            )
                .equatable()
        }
    }
}

// MARK: - Component

public struct MultiSelectCalendarView<Day: View, Header: View, ExcessDay: View>: View {
    // Injected dependencies
    @Binding private var viewDate: Date
    @Binding private var selectedDates: [Date]
    private let content: (Date) -> Day
    private let excessDays: (Date) -> ExcessDay
    private let header: (Date) -> Header
    
    // Constants
    private let daysInWeek = 7
    private var days: [Date] = []
    private let month: Date
    private var weeks: [[Date]] = []
    
    public init(
        viewDate: Binding<Date>,
        selectedDates: Binding<[Date]>,
        @ViewBuilder content: @escaping (Date) -> Day,
        @ViewBuilder excessDays: @escaping (Date) -> ExcessDay,
        @ViewBuilder header: @escaping (Date) -> Header
    ) {
        self._viewDate = viewDate
        self._selectedDates = selectedDates
        self.content = content
        self.excessDays = excessDays
        self.header = header
        
        self.month = viewDate.wrappedValue.startOfMonth(using: Calendar.current)
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
                        if Calendar.current.isDate(self.viewDate, equalTo: month, toGranularity: .month) {
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
}

// MARK: - Conformances

extension MultiSelectCalendarView: Equatable {
    public static func == (lhs: MultiSelectCalendarView<Day, Header, ExcessDay>, rhs: MultiSelectCalendarView<Day, Header, ExcessDay>) -> Bool {
        lhs.viewDate == rhs.viewDate
    }
}

// MARK: - Helpers

private extension MultiSelectCalendarView {
    func makeDays() -> [Date] {
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: self.viewDate),
              let monthFirstWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else {
            return []
        }
        
        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        return Calendar.current.generateDays(for: dateInterval)
    }
}
