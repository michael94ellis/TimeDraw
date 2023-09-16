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
    
    var itemCount: Int { itemList.events.count + itemList.reminders.count }
    
    var body: some View {
        List {
            if self.appSettings.isTimeDrawClockEnabled {
                HStack {
                    Spacer()
                    GeometryReader { geo in
                        TimeDrawClock(width: geo.size.width)
                    }
                    Spacer()
                }
            }
            ForEach(self.itemList.events) { item in
                EventListCell(item: item)
            }
            ForEach(self.itemList.reminders) { item in
                ReminderListCell(item: item)
            }
            Spacer(minLength: itemCount > 0 ? 60 : 0)
        }
        .buttonStyle(.plain)
        .listStyle(.plain)
        .refreshable(action: {
            self.itemList.updateData()
        })
    }
}
