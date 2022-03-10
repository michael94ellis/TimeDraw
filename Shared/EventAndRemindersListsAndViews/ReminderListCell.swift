//
//  ReminderListCell.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/10/22.
//

import SwiftUI
import EventKit


struct ReminderListCell: View {
    
    var item: EKReminder
    @ObservedObject private var eventList: EventListViewModel = .shared
    @EnvironmentObject var floatingModifyViewModel: ModifyCalendarItemViewModel
    @State var showComplete: Bool = false
    @State var showDelete: Bool = false
    
    var body: some View {
        HStack {
            if self.showComplete {
                Button(action: {
                    Task {
                        item.isCompleted = true
                        self.floatingModifyViewModel.save(reminder: item, "Completed")
                        self.floatingModifyViewModel.displayToast("Reminder Completed")
                        self.eventList.updateData()
                    }
                }) {
                    Image(systemName: "checkmark")
                        .foregroundColor(Color.dark)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.green1))
            }
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
                if item.isCompleted, let completionDate = item.completionDate {
                    Text(DateFormatter.timeFormatter.string(from: completionDate))
                        .font(.callout)
                        .foregroundColor(Color(uiColor: .darkGray))
                } else {
                    if let startDate = item.startDateComponents,
                       let startHour = startDate.hour, let startMinute = startDate.minute {
                        let startTime = "\(startHour):\(startMinute < 10 ? "0" : "")\(startMinute) \(startHour > 11 ? "PM" : "AM")"
                        Text("\(startTime)")
                            .font(.callout)
                            .foregroundColor(Color(uiColor: .darkGray))
                    }
                    if let dueDate = item.dueDateComponents,
                       let dueHour = dueDate.hour, let dueMinute = dueDate.minute,
                       let dueTime = "\(dueHour):\(dueMinute < 10 ? "0" : "")\(dueMinute) \(dueHour > 11 ? "PM" : "AM")" {
                        Text(" - \(dueTime)")
                            .font(.callout)
                            .foregroundColor(Color(uiColor: .darkGray))
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.15)))
            if self.showDelete {
                Button(action: {
                    Task {
                        self.eventList.delete(item)
                        self.floatingModifyViewModel.displayToast("Reminder Deleted")
                    }
                }) {
                    Image(systemName: "trash")
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.red1))
            }
        }
        .listRowSeparator(.hidden)
        .gesture(DragGesture(minimumDistance: 50).onEnded({ value in
            withAnimation {
                let direction = value.detectDirection()
                if direction == .left {
                    self.showDelete = false
                    self.showComplete = true
                } else if direction == .right {
                    self.showComplete = false
                    self.showDelete = true
                }
            }
        }).exclusively(before:TapGesture().onEnded({
            withAnimation {
                self.showDelete = false
                self.floatingModifyViewModel.open(reminder: item)
            }
        })))
    }
}
