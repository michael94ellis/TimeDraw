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
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "deskclock")
                    .foregroundColor(Color(uiColor: .darkGray))
                Circle().fill(Color(cgColor: item.calendar.cgColor))
                    .frame(width: 12, height: 12)
                if item.isCompleted {
                    Text(item.title.isEmpty ? "Untitled Reminder" : item.title)
                        .strikethrough()
                        .lineLimit(2)
                        .foregroundColor(Color(uiColor: .darkGray))
                } else {
                    Text(item.title.isEmpty ? "Untitled Reminder" : item.title)
                        .lineLimit(2)
                        .foregroundColor(Color(uiColor: .darkGray))
                }
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
            .padding(.vertical, 4)
            .padding(.horizontal)
        }
        .frame(height: 45)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.15)))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
