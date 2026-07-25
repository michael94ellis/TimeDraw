//
//  CalendarListViewModel.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/5/22.
//

import Dependencies
import EventKit
import SwiftUI

struct CalendarListViewModelKey: DependencyKey {
    static var liveValue: CalendarListViewModel = .init()
}

extension DependencyValues {
    public var calendarListViewModel: CalendarListViewModel {
      get { self[CalendarListViewModelKey.self] }
      set { self[CalendarListViewModelKey.self] = newValue }
    }
}

public final class CalendarListViewModel: ObservableObject {
    
    @Published public var displayDate: Date = Date() {
        didSet {
            guard !isApplyingDisplayDateSilently else { return }
            updateData()
        }
    }
    
    @Published public var events: [EKEvent] = []
    @Published public var reminders: [EKReminder] = []
    @Published public var error: (any Error)?
    
    @AppStorage(EventStorageKey.userSelectedCalendars) private var userSelectedCalendars: Data?
    @AppStorage(EventStorageKey.showCalendarItemType) private var showCalendarItemType: CalendarItemType = .all
    @AppStorage(EventStorageKey.showItemRecurrenceType) private var showItemRecurrenceType: ItemRecurrenceType = .all
    
    @Dependency(\.eventKitManager) private var eventKitManager
    private var isApplyingDisplayDateSilently = false
    
    public init() { }
    
    /// Watch has no calendar picker; always read every calendar the user granted.
    private var calendarFilterIDs: [String] {
        userSelectedCalendars.loadCalendarIds()
    }
    
    /// Ensures `displayDate` is today, then reloads events/reminders.
    public func refreshForToday() async throws {
        try await refreshForTodayAsync()
    }
    
    /// Async variant so watchOS can wait for fetches (and retry if needed).
    @discardableResult
    public func refreshForTodayAsync() async throws -> (events: Int, reminders: Int) {
        let today = Date()
        if !Calendar.current.isDate(displayDate, inSameDayAs: today) {
            isApplyingDisplayDateSilently = true
            displayDate = today
            isApplyingDisplayDateSilently = false
        }
        try await updateDataAsync()
        return (events.count, reminders.count)
    }
    
    public func updateData() {
        Task {
            do {
                try await updateDataAsync()
            } catch let error {
                self.error = error
            }
        }
    }
    
    private func updateDataAsync() async throws {
        let canReadEvents = eventKitManager.eventAuthorizationStatus() == .fullAccess
        let canReadReminders = eventKitManager.reminderAuthorizationStatus() == .fullAccess
        
        switch showCalendarItemType {
        case .scheduled:
            reminders = []
            events = canReadEvents ? try await fetchEvents() : []
        case .unscheduled:
            events = []
            reminders = canReadReminders ? try await fetchReminders() : []
        case .all:
            await withThrowingTaskGroup { group in
                group.addTask {
                    let loadedEvents = try await self.fetchEvents()
                    await MainActor.run {
                        self.events = loadedEvents
                    }
                }
                group.addTask {
                    let loadedReminders = try await self.fetchReminders()
                    await MainActor.run {
                        self.reminders = loadedReminders
                    }
                }
            }
        }
    }
    
    public func fetchEvents() async throws -> [EKEvent] {
        try await fetchEventsForDisplayDate(filterCalendarIDs: calendarFilterIDs)
    }
    
    public func fetchReminders() async throws -> [EKReminder] {
        try await fetchRemindersForDisplayDate(filterCalendarIDs: calendarFilterIDs)
    }
    
    public func completeReminder(_ reminder: EKReminder) {
        reminder.isCompleted = true
    }
    
    // MARK: - Fetch Events
    private func fetchEventsForDisplayDate(filterCalendarIDs: [String] = []) async throws -> [EKEvent] {
        var eventsResult = try await eventKitManager.fetchEvents(
            startDate: displayDate.startOfDay,
            endDate: displayDate.endOfDay,
            calendars: filterCalendarIDs
        )
        switch showItemRecurrenceType {
        case .recurring:
            eventsResult.removeAll(where: { !$0.hasRecurrenceRules })
        case .nonRecurring:
            eventsResult.removeAll(where: { $0.hasRecurrenceRules })
        case .all:
            break
        }
        return eventsResult
    }
    
    // MARK: Fetch Reminders
    private func fetchRemindersForDisplayDate(filterCalendarIDs: [String] = []) async throws -> [EKReminder] {
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
        return filteredReminders
    }
    
    // MARK: - Non Watch Functions
    // Watch OS does not support these actions
    // https://developer.apple.com/forums/thread/42293
    #if !os(watchOS)
    @MainActor
    public func delete(_ item: EKCalendarItem) async throws {
        if let reminder = item as? EKReminder {
            reminders.removeAll(where: { $0 == reminder })
            try await eventKitManager.eventStore.remove(reminder, commit: true)
        } else if let event = item as? EKEvent {
            events.removeAll(where: { $0 == event })
            try await eventKitManager.eventStore.remove(event, span: .futureEvents, commit: true)
        } else {
            assertionFailure("Unexpected Delete Type: \(item.self)")
        }
        updateData()
    }
    #endif
}
