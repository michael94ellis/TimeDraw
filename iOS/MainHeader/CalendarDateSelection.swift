//
//  CalendarDateSelection.swift
//  TimeDraw
//
//  Created by Michael Ellis on 7/23/26.
//

import AppCore
import DesignToken
import SwiftUI

struct CalendarDateSelection: View {
    
    @Binding var showCompactCalendar: Bool
    @Binding private var selectedDate: Date
    @EnvironmentObject var itemList: CalendarItemListViewModel
    
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
                            if UIDevice.current.userInterfaceIdiom == .phone {
                                self.showCompactCalendar.toggle()
                            }
                        }
                    }) {
                        let today = Calendar.current.isDateInToday(date)
                        let display = Calendar.current.isDate(date, inSameDayAs: self.itemList.displayDate)
                        Text("00")
                            .padding(10)
                            .foregroundColor(.clear)
                            .background(display ? Color(uiColor: .systemGray3) : Color(uiColor: .systemBackground))
                            .frame(width: 36, height: 36)
                            .cornerRadius(CornerRadius.calendarDayRadius)
                            .accessibilityHidden(true)
                            .overlay(
                                Text(DateFormatter.dayFormatter.string(from: date))
                                    .font((today || display) ? .interBold : .body)
                                    .foregroundColor(
                                        today ? .red1 :
                                            display ? .white :
                                                .darkGray
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
                            .foregroundColor(Color.gray)
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
