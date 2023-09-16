//
//  EventsAndRemindersMainList.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/20/22.
//

import SwiftUI
import EventKit

struct MainScrollableContent: View {
    
    @EnvironmentObject var itemList: CalendarItemListViewModel
    @ObservedObject private var appSettings: AppSettings = .shared
    let clockHorizPadding: CGFloat = 100
    let clockVertPadding: CGFloat = 20
    
    var itemCount: Int { itemList.events.count + itemList.reminders.count }
    
    var body: some View {
        GeometryReader { geo in
            List {
                if self.appSettings.isTimeDrawClockEnabled {
                    TimeDrawClock(width: geo.size.width - clockHorizPadding)
                        .listRowSeparator(.hidden)
                        .padding(.vertical, clockVertPadding)
                        .padding(.horizontal, clockHorizPadding)
                }
                ForEach(self.itemList.events) { item in
                    EventListCell(item: item)
                        .listRowSeparator(.hidden)
                }
                ForEach(self.itemList.reminders) { item in
                    ReminderListCell(item: item)
                        .listRowSeparator(.hidden)
                }
                Spacer(minLength: itemCount > 0 ? 60 : 0)
                    .listRowSeparator(.hidden)
            }
            .buttonStyle(.plain)
            .listStyle(.plain)
            .refreshable(action: {
                self.itemList.updateData()
            })
        }
    }
}
