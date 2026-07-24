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

public final class CalendarItemListViewModel: ObservableObject {
    
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
        self.reminders = []
        self.events = []
        switch showCalendarItemType {
        case .scheduled:
            self.reminders = []
            if eventKitManager.eventAuthorizationStatus() == .fullAccess {
                self.fetchEvents()
            }
        case .unscheduled:
            self.events = []
            if eventKitManager.eventAuthorizationStatus() == .fullAccess {
                self.fetchReminders()
            }
        case .all:
            if eventKitManager.eventAuthorizationStatus() == .fullAccess {
                self.fetchEvents()
            }
            if eventKitManager.eventAuthorizationStatus() == .fullAccess {
                self.fetchReminders()
            }
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
        Task { @MainActor in
            self.reminders = filteredReminders
        }
    }
    
    
    // MARK: - Non Watch Functions
    // Watch OS does not support these actions
    // https://developer.apple.com/forums/thread/42293
    #if !os(watchOS)
    public func delete(_ item: EKCalendarItem) async {
        if let reminder = item as? EKReminder {
            self.reminders.removeAll(where: { $0 == reminder })
            do {
                try await eventKitManager.eventStore.remove(reminder, commit: true)
            } catch {
                print("Error could not delete reminder: \(error)")
            }
        }
        if let event = item as? EKEvent {
            self.events.removeAll(where: { $0 == event })
            do {
                try await eventKitManager.eventStore.remove(event, span: .futureEvents, commit: true)
            } catch {
                print("Error could not delete event: \(error)")
            }
        }
        self.updateData()
    }
    #endif
}
