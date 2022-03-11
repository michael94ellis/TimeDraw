//
//  EventListCell.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/10/22.
//

import SwiftUI
import EventKit

struct EventListCell: View {
    
    var item: EKEvent
    @ObservedObject private var eventList: EventListViewModel = .shared
    @EnvironmentObject var floatingModifyViewModel: ModifyCalendarItemViewModel
    @State var showDelete: Bool = false
    
    private let timeOnly = DateFormatter()
    
    init(item: EKEvent) {
        self.item = item
        self.timeOnly.dateFormat = "h:mma"
    }
    
    var body: some View {
        HStack {
            HStack {
                if AppSettings.shared.showListIcons {
                    Image(systemName: "calendar")
                        .foregroundColor(Color(uiColor: .darkGray))
                }
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
            if self.showDelete {
                Button(action: {
                    Task {
                        self.eventList.delete(item)
                        self.floatingModifyViewModel.displayToast("Event Deleted")
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
                } else if direction == .right {
                    self.showDelete = true
                } else {
                }
            }
        }).exclusively(before:TapGesture().onEnded({
            withAnimation {
                self.showDelete = false
                self.floatingModifyViewModel.open(event: item)
            }
        })))
    }
}
