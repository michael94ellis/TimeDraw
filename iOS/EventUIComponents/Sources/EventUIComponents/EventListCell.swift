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

    @ViewBuilder
    var cellContent: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.title.isEmpty ? "Untitled Event" : item.title)
                .font(.interSemiBold)
                .foregroundStyle(DesignToken.Colors.primaryText)
                .lineLimit(2)
            Text(subtitle)
                .font(.interFine)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        if item.hasRecurrenceRules {
            Image(systemName: "repeat")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.trailing, 8)
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            
            UnevenRoundedRectangle(
                topLeadingRadius: DesignToken.CornerRadius.listRowRadius,
                bottomLeadingRadius: DesignToken.CornerRadius.listRowRadius,
                bottomTrailingRadius: 0,
                topTrailingRadius: 0
            )
            .fill(Color(cgColor: item.calendar.cgColor))
            .frame(width: 12)
            
            cellContent
                .padding(.vertical, 8)

        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(String(describing: item.title.isEmpty ? "Untitled Event" : item.title)), \(subtitle)")
    }
}
