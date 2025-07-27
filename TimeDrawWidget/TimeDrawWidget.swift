//
//  TimeDrawWidget.swift
//  TimeDrawWidget
//
//  Created by Michael Ellis on 7/26/25.
//

import WidgetKit
import SwiftUI
import EventKit

struct WidgetEntry: TimelineEntry {
    var date: Date
    
    let events: [EKEvent]
    let reminders: [EKReminder]
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> Entry {
        .init(date: .now, events: [], reminders: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping @Sendable (Entry) -> Void) {
//
    }
    
    typealias Entry = WidgetEntry
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct TimeDrawWidgetEntryView: View {
    
    @StateObject private var listViewModel: CalendarItemListViewModel = .init()
    @StateObject private var itemViewModel: ModifyCalendarItemViewModel = .init()
    
    var entry: Provider.Entry

    var body: some View {
        TimeDrawClock(events: listViewModel.events, reminders: listViewModel.reminders)
            .environmentObject(itemViewModel)
    }
}

struct TimeDrawWidget: Widget {
    let kind: String = "TimeDrawWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                TimeDrawWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                TimeDrawWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    TimeDrawWidget()
} timeline: {
    WidgetEntry(date: .now, events: [], reminders: [])
}
