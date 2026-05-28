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

    private var timeSummary: String? {
        if item.isCompleted, let completionDate = item.completionDate {
            return DateFormatter.timeFormatter.string(from: completionDate)
        }
        return CalendarDisplayFormatters.reminderTimeRange(start: item.startDateComponents, due: item.dueDateComponents)
    }

    private var priorityLabel: String? {
        CalendarDisplayFormatters.priorityLabel(for: item.priority)
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(item.isCompleted ? Color.green1 : Color.gray2)

            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color(cgColor: item.calendar.cgColor))
                .frame(width: 4)
                .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title.isEmpty ? "Untitled Reminder" : item.title)
                    .font(.interSemiBold)
                    .foregroundStyle(Color(uiColor: .label))
                    .strikethrough(item.isCompleted, color: .secondary)
                    .lineLimit(2)

                HStack(spacing: 6) {
                    if let timeSummary {
                        Text(timeSummary)
                            .font(.interFine)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    if let priorityLabel {
                        Text(priorityLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer(minLength: 8)

            if let rules = item.recurrenceRules, !rules.isEmpty {
                Image(systemName: "repeat")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .opacity(item.isCompleted ? 0.55 : 1)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    private var accessibilityDescription: String {
        var parts = [item.title.isEmpty ? "Untitled Reminder" : item.title]
        if item.isCompleted { parts.append("completed") }
        if let timeSummary { parts.append(timeSummary) }
        if let priorityLabel { parts.append("\(priorityLabel) priority") }
        return Array(parts).compactMap({ $0 }).joined(separator: ", ")
    }
}
