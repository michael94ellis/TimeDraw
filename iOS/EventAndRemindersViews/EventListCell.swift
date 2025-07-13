//
//  EventListCell.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/10/22.
//

import SwiftUI
import EventKit

struct EventListCell: View {
    
    @EnvironmentObject var itemList: CalendarItemListViewModel
    @EnvironmentObject var modifyItemViewModel: ModifyCalendarItemViewModel
    @EnvironmentObject private var appSettings: AppSettings

    @State var showDelete: Bool = false
    
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
                    self.showDelete = false
                } else if direction == .right {
                    if value.translation.width < -150 {
                        self.itemList.performAsyncDelete(for: self.item)
                        self.modifyItemViewModel.displayToast("Event Deleted")
                    } else {
                        self.showDelete = true
                    }
                }
            }
        }).exclusively(before:TapGesture().onEnded({
            withAnimation {
                self.showDelete = false
                self.modifyItemViewModel.open(event: item)
            }
        })))
    }
}
