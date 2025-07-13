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
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var itemList: CalendarItemListViewModel
    @EnvironmentObject var modifyItemViewModel: ModifyCalendarItemViewModel
    @State var showComplete: Bool = false
    @State var showDelete: Bool = false
    
    func performComplete() {
        self.itemList.performAsyncCompleteReminder(for: self.item)
        self.modifyItemViewModel.saveAndDisplayToast(reminder: self.item, "Completed")
        self.modifyItemViewModel.displayToast("Reminder Completed")
    }
    
    func performDelete() {
        self.itemList.performAsyncDelete(for: self.item)
        self.modifyItemViewModel.displayToast("Event Deleted")
    }
    
    var body: some View {
        HStack {
            HStack {
                if self.showComplete {
                    Button(action: self.performComplete) {
                        VStack {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(Color.dark)
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            Spacer()
                        }
                        .background(Color.green1)
                    }
                    .transition(.move(edge: .leading))
                }
                HStack {
                    if appSettings.showListIcons {
                        Image(systemName: "deskclock")
                            .foregroundColor(Color(uiColor: .darkGray))
                    }
                    Circle().fill(Color(cgColor: item.calendar.cgColor))
                        .frame(width: 12, height: 12)
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
                           let dueHour = dueDate.hour, let dueMinute = dueDate.minute {
                            Text(" - \(dueHour):\(dueMinute < 10 ? "0" : "")\(dueMinute) \(dueHour > 11 ? "PM" : "AM")")
                                .font(.callout)
                                .foregroundColor(Color(uiColor: .darkGray))
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal)
                if self.showDelete {
                    Button(action: {
                        self.itemList.performAsyncDelete(for: self.item)
                        self.modifyItemViewModel.displayToast("Event Deleted")
                    }) {
                        VStack {
                            Spacer()
                            Image(systemName: "trash")
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            Spacer()
                        }
                        .background(Color.red1)
                    }
                    .transition(.move(edge: .trailing))
                }
            }
            .frame(height: 55)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.15)))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .listRowSeparator(.hidden)
        .gesture(DragGesture(minimumDistance: 15)
                    .onChanged({ value in
            withAnimation {
                let direction = value.detectDirection()
                if direction == .left {
                    if value.translation.width > 150 {
                        self.performComplete()
                        self.showDelete = false
                        self.showComplete = false
                    } else {
                        self.showDelete = false
                        self.showComplete = true
                    }
                } else if direction == .right {
                    if value.translation.width < -150 {
                        self.performDelete()
                        self.showDelete = false
                        self.showComplete = false
                    } else {
                        self.showDelete = true
                        self.showComplete = false
                    }
                }
            }
        }).exclusively(before:TapGesture().onEnded({
            withAnimation {
                self.showDelete = false
                self.showComplete = false
                self.modifyItemViewModel.open(reminder: item)
            }
        })))
    }
}
