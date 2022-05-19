//
//  EventsAndRemindersMainList.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/20/22.
//

import SwiftUI
import EventKit

struct EventsAndRemindersMainList: View {
    
    @EnvironmentObject var itemList: CalendarItemListViewModel
    
    var body: some View {
        List {
            ForEach(self.itemList.events) { item in
                EventListCell(item: item)
            }
            ForEach(self.itemList.reminders) { item in
                ReminderListCell(item: item)
            }
            Spacer(minLength: 120)
                .listRowSeparator(.hidden)
        }
        .buttonStyle(.plain)
        .listStyle(.plain)
        .refreshable(action: {
            self.itemList.updateData()
        })
    }
}
