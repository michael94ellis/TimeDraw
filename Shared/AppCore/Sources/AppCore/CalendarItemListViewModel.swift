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
            guard !isApplyingDisplayDateSilently else { return }
            updateData()
        }
    }
    
    @Published public var events: [EKEvent] = []
    @Published public var reminders: [EKReminder] = []
    
    @AppStorage(AppStorageKey.userSelectedCalendars) private var userSelectedCalendars: Data?
    @AppStorage(AppStorageKey.showCalendarItemType) private var showCalendarItemType: CalendarItemType = .all
    @AppStorage(AppStorageKey.showItemRecurrenceType) private var showItemRecurrenceType: ItemRecurrenceType = .all
    
    @Dependency(\.eventKitManager) private var eventKitManager
    private var isApplyingDisplayDateSilently = false
    private var loadTask: Task<Void, Never>?
    
    public init() { }
    
    /// Watch has no calendar picker; always read every calendar the user granted.
    private var calendarFilterIDs: [String] {
        userSelectedCalendars.loadCalendarIds()
    }
    
    /// Ensures `displayDate` is today, then reloads events/reminders.
    public func refreshForToday() {
        Task { await refreshForTodayAsync() }
    }
    
    /// Async variant so watchOS can wait for fetches (and retry if needed).
    @discardableResult
    public func refreshForTodayAsync() async -> (events: Int, reminders: Int) {
        let today = Date()
        if !Calendar.current.isDate(displayDate, inSameDayAs: today) {
            isApplyingDisplayDateSilently = true
            displayDate = today
            isApplyingDisplayDateSilently = false
        }
        await updateDataAsync()
        return (events.count, reminders.count)
    }
    
    public func updateData() {
        loadTask?.cancel()
        loadTask = Task { await updateDataAsync() }
    }
    
    private func updateDataAsync() async {
        let canReadEvents = eventKitManager.eventAuthorizationStatus() == .fullAccess
        let canReadReminders = eventKitManager.reminderAuthorizationStatus() == .fullAccess
        
        switch showCalendarItemType {
        case .scheduled:
            reminders = []
            events = canReadEvents ? await fetchEvents() : []
        case .unscheduled:
            events = []
            reminders = canReadReminders ? await fetchReminders() : []
        case .all:
            await withTaskGroup { group in
                group.addTask {
                    let loadedEvents = await self.fetchEvents()
                    await MainActor.run {
                        self.events = loadedEvents
                    }
                }
                group.addTask {
                    let loadedReminders = await self.fetchReminders()
                    await MainActor.run {
                        self.reminders = loadedReminders
                    }
                }
            }
        }
    }
    
    public func fetchEvents() async -> [EKEvent] {
        do {
            return try await fetchEventsForDisplayDate(filterCalendarIDs: calendarFilterIDs)
        } catch {
            print(error)
            return []
        }
    }
    
    public func fetchReminders() async -> [EKReminder] {
        do {
            return try await fetchRemindersForDisplayDate(filterCalendarIDs: calendarFilterIDs)
        } catch {
            print(error)
            return []
        }
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
    public func delete(_ item: EKCalendarItem) async {
        if let reminder = item as? EKReminder {
            reminders.removeAll(where: { $0 == reminder })
            do {
                try await eventKitManager.eventStore.remove(reminder, commit: true)
            } catch {
                print("Error could not delete reminder: \(error)")
            }
        }
        if let event = item as? EKEvent {
            events.removeAll(where: { $0 == event })
            do {
                try await eventKitManager.eventStore.remove(event, span: .futureEvents, commit: true)
            } catch {
                print("Error could not delete event: \(error)")
            }
        }
        updateData()
    }
    #endif
}
