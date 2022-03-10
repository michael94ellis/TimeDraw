//
//  EventListViewModel.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/5/22.
//

import SwiftUI
import EventKit

@MainActor
class EventListViewModel: ObservableObject {
    
    @Published public var displayDate: Date = Date() {
        didSet {
            self.updateData()
        }
    }
    
    @AppStorage("showCalendarItemType") var showCalendarItemType: CalendarItemType = .events
    @AppStorage("hideRecurringItems") var hideRecurringItems: Bool = false
    @Published public var events: [EKEvent] = []
    @Published public var reminders: [EKReminder] = []
    
    // MARK: Static accessor
    public static let shared = EventListViewModel()
    // This prevents others from using the default '()' initializer for this class.
    private init() {
        self.updateData()
    }
    
    func fetchEvents() {
        Task {
            try await self.fetchEventsForDisplayDate()
        }
    }
    func fetchReminders() {
        Task {
            try await self.fetchRemindersForDisplayDate()
        }
    }
    
    public func updateData() {
        switch self.showCalendarItemType {
        case .events:
            self.fetchEvents()
        case .reminders:
            self.fetchReminders()
        case .all:
            self.fetchEvents()
            self.fetchReminders()
        }
    }
    
    // MARK: - Fetch Events
    /// Fetch events for today
    /// - Parameter filterCalendarIDs: filterable Calendar IDs
    /// Returns: events for today
    public func fetchEventsForDisplayDate(filterCalendarIDs: [String] = []) async throws {
        self.events = try await EventKitManager.shared.fetchEvents(startDate: self.displayDate.startOfDay, endDate: self.displayDate.endOfDay, calendars: filterCalendarIDs)
        if self.hideRecurringItems {
            self.events.removeAll(where: { $0.hasRecurrenceRules })
        }
    }
    
    // MARK: Fetch Reminders
    /// Fetch events for today
    /// - Parameter filterCalendarIDs: filterable Calendar IDs
    /// Returns: events for today
    public func fetchRemindersForDisplayDate() async throws {
        try await EventKitManager.shared.fetchReminders(completion: { reminders in
            // MainActor didnt work for callback
            DispatchQueue.main.async {
                self.reminders = reminders?.filter({ !$0.isCompleted }) ?? []
                if self.hideRecurringItems {
                    self.reminders.removeAll(where: { $0.hasRecurrenceRules })
                }
            }
        })
    }
    
    @MainActor func delete(_ item: EKCalendarItem) {
        if let reminder = item as? EKReminder {
            self.reminders.removeAll(where: { $0 == reminder })
            do {
                try EventKitManager.shared.eventStore.remove(reminder, commit: true)
            } catch  {
                print("Error could not delete reminder: \(error)")
            }
        }
        if let event = item as? EKEvent {
            self.events.removeAll(where: { $0 == event })
            do {
                try EventKitManager.shared.eventStore.remove(event, span: .futureEvents, commit: true)
            } catch  {
                print("Error could not delete event: \(error)")
            }
            self.updateData()
        }
    }
}
