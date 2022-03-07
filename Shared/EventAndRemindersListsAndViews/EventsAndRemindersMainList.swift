//
//  EventsAndRemindersMainList.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/20/22.
//

import SwiftUI

struct EventsAndRemindersMainList: View {
    
    @ObservedObject private var eventList: EventListViewModel = .shared
    @EnvironmentObject var floatingModifyViewModel: ModifyCalendarItemViewModel
    
    private let timeOnly = DateFormatter()
    
    init() {
        self.timeOnly.dateFormat = "h:mma"
    }
    
    var body: some View {
        List {
            ForEach(self.eventList.events) { item in
                Button(action: {
                    self.floatingModifyViewModel.open(event: item)
                }) {
                    HStack {
                        Circle().fill(Color(cgColor: item.calendar.cgColor))
                            .frame(width: 8, height: 8)
                        Text(item.title.isEmpty ? "Untitled Event": item.title)
                            .lineLimit(2)
                            .foregroundColor(Color(uiColor: .darkGray))
                        Spacer()
                        if item.hasRecurrenceRules {
                            Image("repeat")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .font(.subheadline)
                                .foregroundColor(Color(uiColor: .darkGray))
                        }
                        if item.isAllDay {
                            Text("All Day")
                                .font(.caption)
                                .foregroundColor(Color(uiColor: .darkGray))
                        } else {
                            Text("\(self.timeOnly.string(from: item.startDate)) - \(self.timeOnly.string(from: item.endDate))")
                                .font(.callout)
                                .foregroundColor(Color(uiColor: .darkGray))
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.15)))
                }
                .listRowSeparator(.hidden)
            }
            ForEach(self.eventList.reminders) { item in
                Button(action: {
                    withAnimation {
                        self.floatingModifyViewModel.open(reminder: item)
                    }
                }) {
                    HStack {
                        Circle().fill(Color(cgColor: item.calendar.cgColor))
                            .frame(width: 8, height: 8)
                        Text(item.title.isEmpty ? "Untitled Reminder" : item.title)
                            .if(item.isCompleted) { $0.strikethrough() }
                            .lineLimit(2)
                            .foregroundColor(Color(uiColor: .darkGray))
                        Spacer()
                        if let rules = item.recurrenceRules, !rules.isEmpty {
                            Image("repeat")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .font(.subheadline)
                                .foregroundColor(Color(uiColor: .darkGray))
                        }
                        if item.priority > 0 {
                            Text("Priority: \(item.priority)")
                                .font(.caption)
                                .foregroundColor(Color(uiColor: .darkGray))
                        }
                        if let dueDate = item.dueDateComponents {
                            if let startDate = item.startDateComponents {
                                if let dueHour = dueDate.hour, let dueMinute = dueDate.minute {
                                    let dueTime = "\(dueHour):\(dueMinute < 10 ? "0" : "")\(dueMinute) \(dueHour > 11 ? "PM" : "AM")"
                                    if let startHour = startDate.hour, let startMinute = startDate.minute {
                                        let startTime = "\(startHour):\(startMinute < 10 ? "0" : "")\(startMinute) \(startHour > 11 ? "PM" : "AM")"
                                        Text("\(startTime) - \(dueTime)")
                                            .font(.callout)
                                            .foregroundColor(Color(uiColor: .darkGray))
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.15)))
                }
                .listRowSeparator(.hidden)
            }
            Spacer(minLength: 120)
                .listRowSeparator(.hidden)
        }
        .buttonStyle(.plain)
        .listStyle(.plain)
        .refreshable(action: {
            self.eventList.updateData()
        })
    }
}
