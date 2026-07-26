//
//  TimeDrawWidget.swift
//  TimeDrawWidget
//
//  Created by Michael Ellis on 7/26/25.
//

import AppCore
import ClockFace
import EventKit
import EventManagement
import SwiftUI
import WidgetKit

struct WidgetEntry: TimelineEntry {
    var date: Date
    
    let events: [EKEvent]
    let reminders: [EKReminder]
    let highlightColorHex: String
}

struct Provider: TimelineProvider {
    private let eventKitManager = EventKitManager()
    
    func placeholder(in context: Context) -> Entry {
        .init(
            date: .now,
            events: [],
            reminders: [],
            highlightColorHex: AppSettings.defaultHighlightColorHex
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping @Sendable (Entry) -> Void) {
        Task {
            let entry = await fetchData(for: Date())
            completion(entry)
        }
    }
    
    typealias Entry = WidgetEntry
    
    func getTimeline(in context: Context,
                     completion: @escaping (Timeline<Entry>) -> Void) {
        Task {
            let currentDate = Date()
            let entry = await fetchData(for: currentDate)
            
            // Create timeline entries for the next few hours
            var entries: [WidgetEntry] = [entry]
            
            // Add entries for the next 6 hours, updating every hour
            for hourOffset in 1...6 {
                let futureDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate) ?? currentDate
                let futureEntry = await fetchData(for: futureDate)
                entries.append(futureEntry)
            }
            
            // Update the timeline when it ends or when the date changes
            let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate) ?? currentDate
            let timeline = Timeline(entries: entries, policy: .after(nextUpdateDate))
            completion(timeline)
        }
    }
    
    private func fetchData(for date: Date) async -> WidgetEntry {
        let highlightColorHex = UserDefaults.appGroup.string(forKey: AppStorageKey.highlightColorHex)
            ?? AppSettings.defaultHighlightColorHex

        do {
            // Load user selected calendar IDs from standard UserDefaults
            let userDefaults = UserDefaults.standard
            let calendarData = userDefaults.data(forKey: AppStorageKey.userSelectedCalendars)
            let calendarIds = calendarData.loadCalendarIds()
                        
            // Fetch events for the given date
            let events = try await eventKitManager.fetchEvents(
                startDate: date.startOfDay,
                endDate: date.endOfDay,
                calendars: calendarIds
            )
            
            // Fetch reminders
            let reminders = try await eventKitManager.fetchReminders(calendars: calendarIds) ?? []
            let incompleteReminders = reminders.filter { !$0.isCompleted }
            
            return WidgetEntry(
                date: date,
                events: events,
                reminders: incompleteReminders,
                highlightColorHex: highlightColorHex
            )
        } catch {
            assertionFailure("Error fetching widget data: \(error)")
            // Return empty data instead of failing completely
            return WidgetEntry(
                date: date,
                events: [],
                reminders: [],
                highlightColorHex: highlightColorHex
            )
        }
    }
}

struct TimeDrawWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        TimeDrawClock(
            events: entry.events,
            reminders: entry.reminders,
            highlightColorHex: entry.highlightColorHex
        )
    }
}

struct TimeDrawWidget: Widget {
    let kind: String = TimeDrawWidgetKind.clock

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TimeDrawWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("TimeDraw Widget")
        .description("Shows your calendar events and reminders on an analog clock face.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    TimeDrawWidget()
} timeline: {
    WidgetEntry(
        date: .now,
        events: [],
        reminders: [],
        highlightColorHex: AppSettings.defaultHighlightColorHex
    )
}
