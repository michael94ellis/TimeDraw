//
//  EventsAndRemindersMainList.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/20/22.
//

import SwiftUI
import EventKit

struct EventsAndRemindersMainList: View {
    
    @ObservedObject private var eventList: EventListViewModel = .shared
    
    var body: some View {
        List {
            ForEach(self.eventList.events) { item in
                EventListCell(item: item)
            }
            ForEach(self.eventList.reminders) { item in
                ReminderListCell(item: item)
            }
            Spacer(minLength: 120)
                .listRowSeparator(.hidden)
        }
        .buttonStyle(.plain)
        .listStyle(.plain)
        .refreshable(action: {
            self.eventList.updateData()
        })
    }
}
