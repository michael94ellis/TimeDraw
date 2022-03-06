//
//  MainHeader.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/6/22.
//

import SwiftUI

struct MainHeader: View {
    
    @State private var showSettingsPopover = false
    @ObservedObject private var eventList: EventListViewModel = .shared

    private let date: Date
    private let weekdayFormatter = DateFormatter()
    private let monthNameFormatter = DateFormatter()
    
    init(for date: Date) {
        self.date = date
        self.weekdayFormatter.dateFormat = "EEE"
        self.monthNameFormatter.dateFormat = "LLLL"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(self.monthNameFormatter.string(from: self.date))
                    .fontWeight(.semibold)
                    .foregroundColor(Color.red1)
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
            HStack {
                Spacer()
                ForEach(Calendar.current.daysWithSameWeekOfYear(as: date), id: \.self) { date in
                    if Calendar.current.isDateInToday(date) {
                        Button(action: {
                            self.eventList.displayDate = date
                            self.eventList.updateData()
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
                            self.eventList.updateData()
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
                    Spacer()
                }
            }
        }
    }
}
