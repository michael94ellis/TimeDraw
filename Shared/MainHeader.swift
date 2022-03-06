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
    @State private var showCompactCalendar = true
    @ObservedObject private var eventList: EventListViewModel = .shared

    private let date: Date
    private let weekdayFormatter = DateFormatter()
    private let monthNameFormatter = DateFormatter()
    
    init(for date: Date) {
        self.date = date
        self.weekdayFormatter.dateFormat = "EEE"
        self.monthNameFormatter.dateFormat = "LLLL"
    }
    
    var weekHeader: some View {
        HStack {
            ForEach(Calendar.current.daysWithSameWeekOfYear(as: date), id: \.self) { date in
                if Calendar.current.isDateInToday(date) {
                    Button(action: {
                        self.eventList.displayDate = date
                    }) {
                        VStack {
                            Text(self.weekdayFormatter.string(from: date))
                                .padding(.bottom, 5)
                            Text(date.get(.day).formatted())
                                .fontWeight(.semibold)
                                .foregroundColor(Color.red1)
                        }
                        .frame(maxWidth: 45)
                        .padding(.vertical, 10)
                        .if(Calendar.current.isDate(date, inSameDayAs: self.eventList.displayDate)) { view in
                            view.background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.2)))
                        }
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(action: {
                        self.eventList.displayDate = date
                    }) {
                        VStack {
                            Text(self.weekdayFormatter.string(from: date))
                                .foregroundColor(Color.gray2)
                                .padding(.bottom, 5)
                            Text(date.get(.day).formatted())
                        }
                        .frame(maxWidth: 45)
                        .padding(.vertical, 10)
                        .if(Calendar.current.isDate(date, inSameDayAs: self.eventList.displayDate)) { view in
                            view.background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.2)))
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    self.showCompactCalendar.toggle()
                    if self.showCompactCalendar {
                        self.eventList.displayDate = Date()
                    }
                }) {
                    Text(self.monthNameFormatter.string(from: self.date))
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
                self.weekHeader
                    .gesture(DragGesture()
                                .onEnded { value in
                        let direction = value.detectDirection()
                        if direction == .left {
                            print("prev week")
                        } else if direction == .right {
                            print("next week")
                        }
                    })
            } else {
                CalendarDateSelection(calendar: .current, date: self.$eventList.displayDate)
                    .padding(.horizontal, 25)
            }
        }
    }
}
