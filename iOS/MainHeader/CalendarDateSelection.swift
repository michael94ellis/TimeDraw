//
//  CalendarDateSelection.swift
//  TimeDraw
//
//  Created by Michael Ellis on 7/23/26.
//

import AppCore
import DesignToken
import EventUIComponents
import SwiftUI

struct CalendarDateSelection: View {
    
    @Binding var showCompactCalendar: Bool
    @Binding private var selectedDate: Date
    @EnvironmentObject var itemList: CalendarItemListViewModel
    @Environment(\.layoutMetrics) private var layoutMetrics
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    init(date: Binding<Date>, showCompactCalendar: Binding<Bool>) {
        self._showCompactCalendar = showCompactCalendar
        self._selectedDate = date
    }
    
    var body: some View {
        VStack {
            CalendarView(
                date: $selectedDate,
                content: { date in
                    Button(action: {
                        withAnimation {
                            self.selectedDate = date
                            if horizontalSizeClass != .regular {
                                self.showCompactCalendar.toggle()
                            }
                        }
                    }) {
                        let today = Calendar.current.isDateInToday(date)
                        let display = Calendar.current.isDate(date, inSameDayAs: self.itemList.displayDate)
                        Text("00")
                            .padding(layoutMetrics.monthDayHitPadding)
                            .foregroundColor(.clear)
                            .background(
                                display
                                    ? Colors.calendarDaySelectedBackground
                                    : Colors.systemBackground
                            )
                            .frame(width: layoutMetrics.monthDayHitSize, height: layoutMetrics.monthDayHitSize)
                            .cornerRadius(layoutMetrics.calendarDayRadius)
                            .accessibilityHidden(true)
                            .overlay(
                                Text(DateFormatter.dayFormatter.string(from: date))
                                    .font(
                                        (today || display)
                                            ? .app(.dayNumberToday)
                                            : .app(.dayNumber)
                                    )
                                    .foregroundColor(
                                        today ? Colors.today :
                                            display ? Colors.onAccentBackground :
                                                Colors.calendarDayText
                                    )
                            )
                    }
                },
                excessDays: { date in
                    Button(action: {
                        withAnimation {
                            selectedDate = date
                        }
                    }) {
                        Text(DateFormatter.dayFormatter.string(from: date))
                            .foregroundColor(Colors.calendarExcessDayText)
                            .frame(width: layoutMetrics.monthColumnWidth, height: layoutMetrics.monthColumnHeight)
                    }
                },
                header: { date in
                    Text(DateFormatter.weekDayFormatter.string(from: date))
                        .font(.app(.weekday))
                        .frame(width: layoutMetrics.monthColumnWidth, height: layoutMetrics.monthColumnHeight)
                }
            )
                .equatable()
        }
    }
}
