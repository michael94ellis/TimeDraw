//
//  MultiDateSelectCalendar.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/8/22.
//

import SwiftUI
import EventKit

struct CalendarMultiDateSelection: View {
    
    private var viewDate: Date = Date()
    @Binding private var selectedDates: [Int]
    @ObservedObject private var eventList: EventListViewModel = .shared
    
    init(selectedDates: Binding<[Int]>) {
        self._selectedDates = selectedDates
    }
    
    var body: some View {
        VStack {
            MultiSelectCalendarView(
                viewDate: self.viewDate,
                selectedDates: self.$selectedDates,
                content: { date in
                    Button(action: {
                        var newDates: [Int] = []
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
                        let display = self.selectedDates.contains(date)
                        Text("00")
                            .padding(10)
                            .foregroundColor(.clear)
                            .background(display ? Color(uiColor: .systemGray2)
                                        : Color(uiColor: .systemGray6))
                            .frame(width: 40, height: 30)
                            .cornerRadius(8)
                            .accessibilityHidden(true)
                            .overlay(Text(String(date)))
                            .if(display) { view in
                                view.font(.interBold)
                            }
                            .foregroundColor(display ? .white : .gray2)
                    }
                }
            )
                .equatable()
        }
    }
}

// MARK: - Component

public struct MultiSelectCalendarView<Day: View>: View {
    // Injected dependencies
    private var viewDate: Date
    @Binding private var selectedDates: [Int]
    private let content: (Int) -> Day
    
    // Constants
    private let daysInWeek = 7
    private var days: [Int] = []
    private let month: Date
    private var weeks: [[Int]] = []
    
    public init(
        viewDate: Date,
        selectedDates: Binding<[Int]>,
        @ViewBuilder content: @escaping (Int) -> Day
    ) {
        self.viewDate = viewDate
        self._selectedDates = selectedDates
        self.content = content
        
        self.month = viewDate.startOfMonth(using: Calendar.current)
        let displayDates = Array(1...31)
        self.days = displayDates
        self.weeks = displayDates.chunked(into: 7)
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            ForEach(self.weeks, id: \.self) { week in
                HStack {
                    ForEach(week, id: \.self) { day in
                        self.content(day)
                    }
                }
            }
        }
    }
}

// MARK: - Conformances

extension MultiSelectCalendarView: Equatable {
    public static func == (lhs: MultiSelectCalendarView<Day>, rhs: MultiSelectCalendarView<Day>) -> Bool {
        lhs.viewDate == rhs.viewDate
    }
}
