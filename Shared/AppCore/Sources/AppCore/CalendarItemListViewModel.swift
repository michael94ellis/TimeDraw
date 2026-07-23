//
//  CalendarItemListViewModel.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/5/22.
//

import Dependencies
import EventKit
import SwiftUI

struct CalendarListViewModelKey: DependencyKey {
    static var liveValue: CalendarItemListViewModel = .init()
}

extension DependencyValues {
    public var calendarListViewModel: CalendarItemListViewModel {
      get { self[CalendarListViewModelKey.self] }
      set { self[CalendarListViewModelKey.self] = newValue }
    }
}

public class CalendarItemListViewModel: ObservableObject {
    
    @Published public var displayDate: Date = Date() {
        didSet {
            Task { @MainActor in
                self.updateData()
            }
        }
    }
    
    @Published public var events: [EKEvent] = []
    @Published public var reminders: [EKReminder] = []
    
    @AppStorage(AppStorageKey.userSelectedCalendars) private var userSelectedCalendars: Data?
    @AppStorage(AppStorageKey.showCalendarItemType) private var showCalendarItemType: CalendarItemType = .all
    @AppStorage(AppStorageKey.showItemRecurrenceType) private var showItemRecurrenceType: ItemRecurrenceType = .all
    
    @Dependency(\.eventKitManager) private var eventKitManager
    
    public init() { }
    
    public func fetchEvents() {
        Task {
            do {
                try await self.fetchEventsForDisplayDate(filterCalendarIDs: userSelectedCalendars.loadCalendarIds())
            } catch {
                print(error)
            }
        }
    }
    public func fetchReminders() {
        Task {
            do {
                try await self.fetchRemindersForDisplayDate(filterCalendarIDs: userSelectedCalendars.loadCalendarIds())
            } catch {
                print(error)
            }
        }
    }
    
    public func updateData() {
        switch showCalendarItemType {
        case .scheduled:
            self.reminders = []
            self.fetchEvents()
        case .unscheduled:
            self.events = []
            self.fetchReminders()
        case .all:
            self.fetchEvents()
            self.fetchReminders()
        }
    }
    
    public func completeReminder(_ reminder: EKReminder) {
        reminder.isCompleted = true
    }
    
    // MARK: - Fetch Events
    /// Fetch events for today
    /// - Parameter filterCalendarIDs: filterable Calendar IDs
    /// Returns: events for today
    private func fetchEventsForDisplayDate(filterCalendarIDs: [String] = []) async throws {
        var eventsResult = try await eventKitManager.fetchEvents(startDate: self.displayDate.startOfDay, endDate: self.displayDate.endOfDay, calendars: filterCalendarIDs)
        switch showItemRecurrenceType {
        case .recurring:
            eventsResult.removeAll(where: { !$0.hasRecurrenceRules })
        case .nonRecurring:
            eventsResult.removeAll(where: { $0.hasRecurrenceRules })
        case .all:
            break
        }
        Task { @MainActor in
            self.events = eventsResult
        }
    }
    
    // MARK: Fetch Reminders
    /// Fetch events for today
    /// - Parameter filterCalendarIDs: filterable Calendar IDs
    /// Returns: events for today
    @MainActor
    private func fetchRemindersForDisplayDate(filterCalendarIDs: [String] = []) async throws {
        let reminders = try await eventKitManager.fetchReminders(calendars: filterCalendarIDs)
        var filteredReminders = reminders?.filter({ !$0.isCompleted }) ?? []
        switch showItemRecurrenceType {
        case .recurring:
            filteredReminders.removeAll(where: { !$0.hasRecurrenceRules })
        case .nonRecurring:
            filteredReminders.removeAll(where: { $0.hasRecurrenceRules })
        case .all:
            break
        }
        self.reminders = filteredReminders
    }
    
    
    // MARK: - Non Watch Functions
    // Watch OS does not support these actions
    // https://developer.apple.com/forums/thread/42293
    #if !os(watchOS)
    
    @MainActor public func delete(_ item: EKCalendarItem) {
        if let reminder = item as? EKReminder {
            self.reminders.removeAll(where: { $0 == reminder })
            do {
                try eventKitManager.eventStore.remove(reminder, commit: true)
            } catch {
                print("Error could not delete reminder: \(error)")
            }
        }
        if let event = item as? EKEvent {
            self.events.removeAll(where: { $0 == event })
            do {
                try eventKitManager.eventStore.remove(event, span: .futureEvents, commit: true)
            } catch {
                print("Error could not delete event: \(error)")
            }
        }
        self.updateData()
    }
    #endif
}
