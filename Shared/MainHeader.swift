//
//  MainHeader.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/6/22.
//

import SwiftUI

enum SwipeDirection: String {
    case left, right, up, down, none
}

extension DragGesture.Value {
    func detectDirection() -> SwipeDirection {
        if self.startLocation.x < self.location.x - 24 {
            return .left
        }
        if self.startLocation.x > self.location.x + 24 {
            return .right
        }
        if self.startLocation.y < self.location.y - 24 {
            return .down
        }
        if self.startLocation.y > self.location.y + 24 {
            return .up
        }
        return .none
    }
}

struct MainHeader: View {
    
    @State private var showSettingsPopover = false
    @AppStorage("compactHeader") private var showCompactCalendar = true
    @ObservedObject private var eventList: EventListViewModel = .shared

    private let date: Date
    private let weekdayFormatter = DateFormatter()
    private let monthYearFormatter = DateFormatter()
    
    init(for date: Date) {
        self.date = date
        self.weekdayFormatter.dateFormat = "EEE"
        self.monthYearFormatter.dateFormat = "LLLL YYYY"
    }
    
    func weekDayHeader(for date: Date) -> some View {
        Button(action: {
            self.eventList.displayDate = date
        }) {
            VStack {
                if Calendar.current.isDateInToday(date) {
                    Text(self.weekdayFormatter.string(from: date))
                        .frame(width: 45, height: 30)
                    Text(date.get(.day).formatted())
                        .fontWeight(.semibold)
                        .foregroundColor(Color.red1)
                } else if Calendar.current.isDate(date, inSameDayAs: self.eventList.displayDate) {
                    Text(self.weekdayFormatter.string(from: date))
                        .frame(width: 45, height: 30)
                    Text(date.get(.day).formatted())
                } else {
                    Text(self.weekdayFormatter.string(from: date))
                        .frame(width: 45, height: 30)
                        .foregroundColor(Color.gray2)
                    Text(date.get(.day).formatted())
                }
            }
            .frame(width: 45)
            .padding(.vertical, 8)
            .if(Calendar.current.isDate(date, inSameDayAs: self.eventList.displayDate)) { view in
                view.background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.2)))
            }
        }
        .buttonStyle(.plain)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    self.showCompactCalendar.toggle()
                }) {
                    Text(self.monthYearFormatter.string(from: self.eventList.displayDate))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.red1)
                }
                Spacer()
                Menu(content: {
                    Button("Settings", action: { self.showSettingsPopover.toggle() })
                    Button("Feedback", action: { })
                }, label: { Image(systemName: "ellipsis")
                    .frame(width: 40, height: 30) })
                    .fullScreenCover(isPresented: self.$showSettingsPopover, content: {
                        SettingsView(display: $showSettingsPopover)
                    })
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 10)
            if self.showCompactCalendar {
                HStack {
                    ForEach(Calendar.current.daysWithSameWeekOfYear(as: self.eventList.displayDate), id: \.self) { date in
                        self.weekDayHeader(for: date)
                    }
                }.gesture(DragGesture()
                            .onEnded { value in
                    let direction = value.detectDirection()
                    if direction == .left {
                        self.eventList.displayDate = Calendar.current.date(byAdding: .day, value: -7, to: self.eventList.displayDate) ?? Date()
                    } else if direction == .right {
                        self.eventList.displayDate = Calendar.current.date(byAdding: .day, value: 7, to: self.eventList.displayDate) ?? Date()
                    }
                })
            } else {
                CalendarDateSelection(calendar: .current, date: self.$eventList.displayDate)
                    .gesture(DragGesture()
                                .onEnded { value in
                        let direction = value.detectDirection()
                        if direction == .left {
                            self.eventList.displayDate = Calendar.current.date(byAdding: .month, value: -1, to: self.eventList.displayDate) ?? Date()
                        } else if direction == .right {
                            self.eventList.displayDate = Calendar.current.date(byAdding: .month, value: 1, to: self.eventList.displayDate) ?? Date()
                        }
                    })
            }
        }
    }
}
