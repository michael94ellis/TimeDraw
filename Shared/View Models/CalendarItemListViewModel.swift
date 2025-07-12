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
        if !AppSettings.shared.isFirstAppOpen {
            self.updateData()
        }
    }
    
    func fetchEvents() {
        Task {
            do {
                try await self.fetchEventsForDisplayDate(filterCalendarIDs: AppSettings.shared.userSelectedCalendars.loadCalendarIds())
            } catch {
                print(error)
            }
        }
    }
    func fetchReminders() {
        Task {
            do {
                try await self.fetchRemindersForDisplayDate(filterCalendarIDs: AppSettings.shared.userSelectedCalendars.loadCalendarIds())
            } catch {
                print(error)
            }
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
    private func fetchEventsForDisplayDate(filterCalendarIDs: [String] = []) async throws {
        var eventsResult = try await EventKitManager.shared.fetchEvents(startDate: self.displayDate.startOfDay, endDate: self.displayDate.endOfDay, calendars: filterCalendarIDs)
        if !AppSettings.shared.showRecurringItems {
            eventsResult.removeAll(where: { $0.hasRecurrenceRules })
        }
        DispatchQueue.main.async {
            self.events = eventsResult
        }
    }
    
    // MARK: Fetch Reminders
    /// Fetch events for today
    /// - Parameter filterCalendarIDs: filterable Calendar IDs
    /// Returns: events for today
    private func fetchRemindersForDisplayDate(filterCalendarIDs: [String] = []) async throws {
        try await EventKitManager.shared.fetchReminders(calendars: filterCalendarIDs, completion: { reminders in
            if !AppSettings.shared.showRecurringItems {
                self.reminders.removeAll(where: { $0.hasRecurrenceRules })
            }
            DispatchQueue.main.async {
                self.reminders = reminders?.filter({ !$0.isCompleted }) ?? []
            }
        })
    }
    
    
    // MARK: - Non Watch Functions
    // Watch OS does not support these actions
    // https://developer.apple.com/forums/thread/42293
    #if !os(watchOS)
    
    /// For EKCalendarItmes
    func performAsyncDelete(for item: EKCalendarItem) {
        Task {
            self.delete(item)
        }
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
    #endif
}
