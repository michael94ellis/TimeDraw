//
//  CalendarItemListViewModel.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/5/22.
//

import SwiftUI
import EventKit

@MainActor
class CalendarItemListViewModel: ObservableObject {
    
    @Published public var displayDate: Date = Date() {
        didSet {
            self.updateData()
        }
    }
    
    @Published public var events: [EKEvent] = []
    @Published public var reminders: [EKReminder] = []
    
    // MARK: Static accessor
    public static let shared = CalendarItemListViewModel()
    // This prevents others from using the default '()' initializer for this class.
    private init() {
        self.updateData()
    }
    
    func fetchEvents() {
        Task {
            try await self.fetchEventsForDisplayDate(filterCalendarIDs: AppSettings.shared.userSelectedCalendars.loadCalendarIds())
        }
    }
    func fetchReminders() {
        Task {
            try await self.fetchRemindersForDisplayDate(filterCalendarIDs: AppSettings.shared.userSelectedCalendars.loadCalendarIds())
        }
    }
    
    public func updateData() {
        self.events = []
        self.reminders = []
        switch AppSettings.shared.showCalendarItemType {
        case .scheduled:
            self.fetchEvents()
        case .unscheduled:
            self.fetchReminders()
        case .all:
            self.fetchEvents()
            self.fetchReminders()
        }
    }
    
    /// For EKCalendarItmes
    func performAsyncDelete(for item: EKCalendarItem) {
        Task {
            self.delete(item)
        }
    }
    
    func performAsyncCompleteReminder(for reminder: EKReminder) {
        Task {
            reminder.isCompleted = true
            self.updateData()
        }
    }
    
    // MARK: - Fetch Events
    /// Fetch events for today
    /// - Parameter filterCalendarIDs: filterable Calendar IDs
    /// Returns: events for today
    public func fetchEventsForDisplayDate(filterCalendarIDs: [String] = []) async throws {
        self.events = try await EventKitManager.shared.fetchEvents(startDate: self.displayDate.startOfDay, endDate: self.displayDate.endOfDay, calendars: filterCalendarIDs)
        if !AppSettings.shared.showRecurringItems {
            self.events.removeAll(where: { $0.hasRecurrenceRules })
        }
    }
    
    // MARK: Fetch Reminders
    /// Fetch events for today
    /// - Parameter filterCalendarIDs: filterable Calendar IDs
    /// Returns: events for today
    public func fetchRemindersForDisplayDate(filterCalendarIDs: [String] = []) async throws {
        try await EventKitManager.shared.fetchReminders(calendars: filterCalendarIDs, completion: { reminders in
            // MainActor didnt work for callback
            DispatchQueue.main.async {
                self.reminders = reminders?.filter({ !$0.isCompleted }) ?? []
                if !AppSettings.shared.showRecurringItems {
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
