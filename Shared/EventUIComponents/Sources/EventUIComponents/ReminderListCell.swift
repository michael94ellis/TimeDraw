//
//  ReminderListCell.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/10/22.
//

import DesignToken
import EventKit
import Foundation
import SwiftUI

public struct ReminderListCell: View {

    var item: EKReminder
    
    public init(item: EKReminder) {
        self.item = item
    }

    private var timeSummary: String? {
        if item.isCompleted, let completionDate = item.completionDate {
            return DateFormatter.timeFormatter.string(from: completionDate)
        }
        return CalendarDisplayFormatters.reminderTimeRange(start: item.startDateComponents, due: item.dueDateComponents)
    }

    private var priorityLabel: String? {
        CalendarDisplayFormatters.priorityLabel(for: item.priority)
    }
    
    @ViewBuilder
    var cellContent: some View {
        Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
            .font(.title3)
                .foregroundStyle(item.isCompleted ? Colors.completed : Colors.mutedText)

        VStack(alignment: .leading, spacing: 2) {
            Text(item.title.isEmpty ? "Untitled Reminder" : item.title)
                .font(.interSemiBold)
                .foregroundStyle(Colors.primaryText)
                .strikethrough(item.isCompleted, color: .secondary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

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

        if let rules = item.recurrenceRules, !rules.isEmpty {
            Image(systemName: "repeat")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
        }
    }

    public var body: some View {
        HStack(spacing: 12) {
            
            UnevenRoundedRectangle(
                topLeadingRadius: CornerRadius.listRowRadius,
                bottomLeadingRadius: CornerRadius.listRowRadius,
                bottomTrailingRadius: 0,
                topTrailingRadius: 0
            )
            .fill(Color(cgColor: item.calendar.cgColor))
            .frame(width: 12)
            
            cellContent
                .padding(.vertical, 8)
        }
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
