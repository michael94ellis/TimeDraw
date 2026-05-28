//
//  EventListCell.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/10/22.
//

import SwiftUI
import EventKit

struct EventListCell: View {

    private var item: EKEvent

    init(item: EKEvent) {
        self.item = item
    }

    private var subtitle: String {
        if item.isAllDay {
            return "All Day"
        }
        return CalendarDisplayFormatters.eventTimeRange(from: item.startDate, to: item.endDate, isAllDay: false)
    }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color(cgColor: item.calendar.cgColor))
                .frame(width: 4)
                .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title.isEmpty ? "Untitled Event" : item.title)
                    .font(.interSemiBold)
                    .foregroundStyle(Color(uiColor: .label))
                    .lineLimit(2)
                Text(subtitle)
                    .font(.interFine)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            if item.hasRecurrenceRules {
                Image(systemName: "repeat")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title.isEmpty ? "Untitled Event" : item.title), \(subtitle)")
    }
}
