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
    
    /// Used to display the toast for when new things are mode
    @Published var displayToast: Bool = false
    @Published var toastMessage: String = ""
    
    @Published public var events: [EKEvent] = []
    @Published public var reminders: [EKReminder] = []
    
    // MARK: Static accessor
    public static let shared = EventListViewModel()
    // This prevents others from using the default '()' initializer for this class.
    private init() {
        self.updateData()
    }
    
    public func updateData() {
        Task {
            try await self.fetchEventsForDisplayDate()
        }
        Task {
            try await self.fetchRemindersForDisplayDate()
        }
    }
    
    // MARK: - Fetch Events
    /// Fetch events for today
    /// - Parameter filterCalendarIDs: filterable Calendar IDs
    /// Returns: events for today
    public func fetchEventsForDisplayDate(filterCalendarIDs: [String] = []) async throws {
        self.events = try await EventKitManager.shared.fetchEvents(startDate: self.displayDate.startOfDay, endDate: self.displayDate.endOfDay, filterCalendarIDs: filterCalendarIDs)
    }
    
    // MARK: Fetch Reminders
    /// Fetch events for today
    /// - Parameter filterCalendarIDs: filterable Calendar IDs
    /// Returns: events for today
    public func fetchRemindersForDisplayDate() async throws {
        try await EventKitManager.shared.fetchReminders(start: self.displayDate.startOfDay, end: self.displayDate.endOfDay, completion: { reminders in
            // MainActor didnt work for callback
            DispatchQueue.main.async {
                self.reminders = reminders ?? []
            }
        })
    }
    
    /// Update the Toast notification to alert the user
    @MainActor public func displayToast(_ message: String) {
        self.toastMessage = message
        self.displayToast = true
    }
    
    @MainActor func delete(_ item: EKCalendarItem) {
        if let reminder = item as? EKReminder {
            do {
                try EventKitManager.shared.eventStore.deleteReminder(identifier: reminder.calendarItemIdentifier)
            } catch  {
                print(error)
            }
            self.save(reminder: reminder, "Reminder Deleted")
        }
        if let event = item as? EKEvent {
            do {
                try EventKitManager.shared.eventStore.deleteEvent(identifier: event.eventIdentifier, span: .futureEvents)
            } catch  {
                print(error)
            }
            self.save(event: event, "Event Deleted")
        }
    }
    
    @MainActor private func save(event: EKEvent, _ message: String) {
        do {
            try EventKitManager.shared.eventStore.save(event, span: .futureEvents)
        } catch  {
            print(error)
        }
        self.displayToast(message)
        self.updateData()
    }
    
    
    @MainActor public func save(reminder: EKReminder, _ message: String) {
        try? EventKitManager.shared.eventStore.save(reminder, commit: true)
        self.displayToast(message)
        self.updateData()
    }
}
