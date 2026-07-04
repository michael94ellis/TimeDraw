//
//  EventKitManager.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/4/22.
//

import Dependencies
import EventKit
import SwiftUI

struct EventKitManagerKey: DependencyKey {
    static var liveValue: EventKitManager = .init()
}

extension DependencyValues {
    var eventKitManager: EventKitManager {
      get { self[EventKitManagerKey.self] }
      set { self[EventKitManagerKey.self] = newValue }
    }
}

public final class EventKitManager {
    
    public static var appName: String = "TimeDraw"

    /// Event store: An object that accesses the user’s calendar and reminder events and supports the scheduling of new events.
    public private(set) var eventStore = EKEventStore()

    public func configureWithAppName(_ appName: String) {
        Self.appName = appName
    }
    
    init() { }
    
    /// Returns calendar object from event kit
    public var defaultEventCalendar: EKCalendar? {
        self.eventStore.calendarForEvents()
    }
    /// Returns calendar object from event kit
    public var defaultReminderCalendar: EKCalendar? {
        self.eventStore.calendarForReminders()
    }
    
    private func eventsAvailabilityCheck() async throws {
        let authorization = try await determineEventStoreAuthorization()
        guard authorization == .fullAccess else {
            throw EventError.eventAuthorizationStatus(authorization)
        }
    }
    
    private func remindersAvailabilityCheck() async throws {
        let authorization = try await determineReminderStoreAuthorization()
        guard authorization == .fullAccess else {
            throw EventError.eventAuthorizationStatus(authorization)
        }
    }
    
    // MARK: - Fetch
    
    /// Fetch events for a specific day
    /// - Parameters:
    ///   - date: day to fetch events from
    ///   - filterCalendarIDs: filterable Calendar IDs
    /// Returns: events
    @discardableResult
    public func fetchEvents(for date: Date, calendars filterCalendarIDs: [String] = []) async throws -> [EKEvent] {
        try await fetchEvents(startDate: date.startOfDay, endDate: date.endOfDay, calendars: filterCalendarIDs)
    }

    /// Fetch events for a specific day
    /// - Parameters:
    ///   - date: day to fetch events from
    ///   - startDate: event start date
    ///   - filterCalendarIDs: filterable Calendar IDs
    /// Returns: events
    @discardableResult
    public func fetchEventsRangeUntilEndOfDay(from startDate: Date, calendars filterCalendarIDs: [String] = []) async throws -> [EKEvent] {
        try await fetchEvents(startDate: startDate, endDate: startDate.endOfDay, calendars: filterCalendarIDs)
    }
    
    /// Fetch events from date range
    /// - Parameters:
    ///   - startDate: start date range
    ///   - endDate: end date range
    ///   - filterCalendarIDs: filterable Calendar IDs
    /// Returns: events
    @discardableResult
    public func fetchEvents(startDate: Date, endDate: Date, calendars filterCalendarIDs: [String] = []) async throws -> [EKEvent] {
        try await eventsAvailabilityCheck()
        let calendars = self.eventStore.calendars(for: .event).filter { calendar in
            if filterCalendarIDs.isEmpty { return true }
            return filterCalendarIDs.contains(calendar.calendarIdentifier)
        }
        let predicate = self.eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        let events = self.eventStore.events(matching: predicate)
        return events
    }
    
    /// Fetch all reminders
    /// - Parameters:
    ///   - filterCalendarIDs: filterable Calendar IDs
    public func fetchReminders(calendars filterCalendarIDs: [String] = []) async throws -> [EKReminder]? {
        try await remindersAvailabilityCheck()
        let calendars = self.eventStore.calendars(for: .reminder).filter { calendar in
            if filterCalendarIDs.isEmpty {
                return true
            }
            return filterCalendarIDs.contains(calendar.calendarIdentifier)
        }
        let predicate = self.eventStore.predicateForReminders(in: calendars)
        return await withCheckedContinuation { continuation in
            self.eventStore.fetchReminders(matching: predicate, completion: {
                continuation.resume(returning: $0)
            })
        }
    }
    
    /// Fetch reminders from date range
    /// - Parameters:
    ///   - startDate: start date range
    ///   - endDate: end date range
    ///   - filterCalendarIDs: filterable Calendar IDs
    public func fetchReminders(start: Date, end: Date, calendars filterCalendarIDs: [String] = []) async throws -> [EKReminder]? {
        try await remindersAvailabilityCheck()
        let calendars = self.eventStore.calendars(for: .reminder).filter { calendar in
            if filterCalendarIDs.isEmpty { return true }
            return filterCalendarIDs.contains(calendar.calendarIdentifier)
        }
        let predicate = self.eventStore.predicateForReminders(in: calendars)
        return await withCheckedContinuation { continuation in
            self.eventStore.fetchReminders(matching: predicate, completion: {
                continuation.resume(returning: $0)
            })
        }
    }
    
    public func eventAuthorizationStatus() -> EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }

    public func reminderAuthorizationStatus() -> EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .reminder)
    }

    public func isEventAccessGranted(_ status: EKAuthorizationStatus) -> Bool {
        status == .fullAccess
    }

    public func isReminderAccessGranted(_ status: EKAuthorizationStatus) -> Bool {
        status == .fullAccess
    }

    /// Check event store authorization for Events without prompting.
    public func determineEventStoreAuthorization() async throws -> EKAuthorizationStatus {
        let currentAuthStatus = eventAuthorizationStatus()
        if isEventAccessGranted(currentAuthStatus) {
            return currentAuthStatus
        }
        throw EventError.eventAuthorizationStatus(currentAuthStatus)
    }

    /// Check reminder store authorization without prompting.
    public func determineReminderStoreAuthorization() async throws -> EKAuthorizationStatus {
        let currentAuthStatus = reminderAuthorizationStatus()
        if isReminderAccessGranted(currentAuthStatus) {
            return currentAuthStatus
        }
        throw EventError.eventAuthorizationStatus(currentAuthStatus)
    }

    @discardableResult
    public func requestEventAccess() async throws -> Bool {
        let granted = try await eventStore.requestFullAccessToEvents()
        if granted {
            self.eventStore = EKEventStore()
        }
        return granted
    }

    @discardableResult
    public func requestReminderAccess() async throws -> Bool {
        let granted = try await eventStore.requestFullAccessToReminders()
        if granted {
            self.eventStore = EKEventStore()
        }
        return granted
    }
    
    // MARK: - Non Watch Functions
    // Watch OS does not support these actions
    // https://developer.apple.com/forums/thread/42293
    #if !os(watchOS)
    // MARK: - CRUD
    /// Create an event
    /// - Parameters:
    ///   - title: title of the event
    ///   - startDate: event's start date
    ///   - endDate: event's end date
    ///   - span: event's span
    ///   - isAllDay: is all day event
    /// - Returns: created event
    public func createEvent(
        _ title: String,
        on calendar: EKCalendar,
        startDate: Date,
        endDate: Date?,
        span: EKSpan = .thisEvent,
        isAllDay: Bool = false
    ) async throws -> EKEvent {
        let createdEvent = try self.eventStore.createEvent(title: title, startDate: startDate, endDate: endDate, calendar: calendar, span: span, isAllDay: isAllDay)
        return createdEvent
    }
    
    /// Create a Reminder
    /// - Parameters:
    ///   - title: title of the reminder
    /// - Returns: created reminder
    public func createReminder(
        _ title: String,
        on calendar: EKCalendar,
        startDate: DateComponents?,
        dueDate: DateComponents?
    ) async throws -> EKReminder {
        self.eventStore.calendars(for: .reminder)
        let newReminder = try self.eventStore.createReminder(title: title, startDate: startDate, dueDate: dueDate, calendar: calendar)
        return newReminder
    }
    
    /// Delete an event
    /// - Parameters:
    ///   - identifier: event identifier
    ///   - span: event span
    public func deleteEvent(
        identifier: String,
        span: EKSpan = .thisEvent
    ) async throws {
        try await accessEventsCalendar()
        try self.eventStore.deleteEvent(identifier: identifier, span: span)
    }
    
    /// Delete a reminder
    /// - Parameters:
    ///   - identifier: event identifier
    public func deleteReminder(
        identifier: String
    ) async throws {
        try await accessEventsCalendar()
        try self.eventStore.deleteReminder(identifier: identifier)
    }
    #endif
    
    // MARK: Access Calendars
    
    /// Request access to Events calendar
    /// - Returns: calendar object
    @discardableResult
    func accessEventsCalendar() async throws -> EKCalendar {
        try await eventsAvailabilityCheck()
        guard let calendar = eventStore.calendarForEvents() else {
            throw EventError.unableToAccessCalendar
        }
        return calendar
    }
    /// Request access to Reminders calendar
    /// - Returns: calendar object
    @discardableResult
    func accessRemindersCalendar() async throws -> EKCalendar {
        try await remindersAvailabilityCheck()
        guard let calendar = eventStore.calendarForReminders() else {
            throw EventError.unableToAccessCalendar
        }
        return calendar
    }
}
