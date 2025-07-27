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
    private let timeOnly = DateFormatter()
    
    init(item: EKEvent) {
        self.item = item
        self.timeOnly.dateFormat = "h:mma"
    }
    
    var body: some View {
        HStack {
            HStack {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(Color(uiColor: .darkGray))
                    if item.calendar != nil {
                        Circle().fill(Color(cgColor: item.calendar.cgColor))
                            .frame(width: 12, height: 12)
                    }
                    Text(item.title.isEmpty ? "Untitled Event": item.title)
                        .lineLimit(2)
                        .foregroundColor(Color(uiColor: .darkGray))
                    Spacer()
                    if item.isAllDay {
                        Text("All Day")
                            .font(.interSemiBold)
                            .foregroundColor(Color(uiColor: .darkGray))
                    } else if item.hasRecurrenceRules {
                        Image("repeat")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .font(.subheadline)
                            .foregroundColor(Color(uiColor: .darkGray))
                    } else {
                        Text("\(self.timeOnly.string(from: item.startDate)) - \(self.timeOnly.string(from: item.endDate))")
                            .font(.callout)
                            .foregroundColor(Color(uiColor: .darkGray))
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal)
            }
            .frame(height: 45)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.15)))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .contentShape(Rectangle())
    }
}
