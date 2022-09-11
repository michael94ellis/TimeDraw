//
//  EventKitManager.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/4/22.
//

import SwiftUI
import EventKit

public final class EventKitManager {
    
    public static var appName: String?

    /// Event store: An object that accesses the user’s calendar and reminder events and supports the scheduling of new events.
    public private(set) var eventStore = EKEventStore()

    public static func configureWithAppName(_ appName: String) {
        self.appName = appName
    }
    
    // MARK: Static accessor
    public static let shared = EventKitManager()

    private init() {} // This prevents others from using the default '()' initializer for this class.
    
    /// Returns calendar object from event kit
    public var defaultEventCalendar: EKCalendar? {
        self.eventStore.calendarForEvents()
    }
    /// Returns calendar object from event kit
    public var defaultReminderCalendar: EKCalendar? {
        self.eventStore.calendarForReminders()
    }
    
    // MARK: - Fetch
    
    /// Fetch events for a specific day
    /// - Parameters:
    ///   - date: day to fetch events from
    ///   - completion: completion handler
    ///   - filterCalendarIDs: filterable Calendar IDs
    /// Returns: events
    @discardableResult
    public func fetchEvents(for date: Date, calendars filterCalendarIDs: [String] = []) async throws -> [EKEvent] {
        try await fetchEvents(startDate: date.startOfDay, endDate: date.endOfDay, calendars: filterCalendarIDs)
    }

    /// Fetch events for a specific day
    /// - Parameters:
    ///   - date: day to fetch events from
    ///   - completion: completion handler
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
    ///   - completion: completion handler
    ///   - filterCalendarIDs: filterable Calendar IDs
    /// Returns: events
    @discardableResult
    public func fetchEvents(startDate: Date, endDate: Date, calendars filterCalendarIDs: [String] = []) async throws -> [EKEvent] {
        let authorization = try await determineEventStoreAuthorization()
        guard authorization == .authorized else {
            throw EventError.eventAuthorizationStatus(authorization)
        }
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
    ///   - completion: completion handler
    ///   - filterCalendarIDs: filterable Calendar IDs
    /// Returns: events
    public func fetchReminders(calendars filterCalendarIDs: [String] = [], completion: @escaping (([EKReminder]?) -> ())) async throws {
        let authorization = try await determineReminderStoreAuthorization()
        guard authorization == .authorized else {
            throw EventError.eventAuthorizationStatus(authorization)
        }
        let calendars = self.eventStore.calendars(for: .reminder).filter { calendar in
            if filterCalendarIDs.isEmpty { return true }
            return filterCalendarIDs.contains(calendar.calendarIdentifier)
        }
        let predicate = self.eventStore.predicateForReminders(in: calendars)
        self.eventStore.fetchReminders(matching: predicate, completion: completion)
    }
    
    /// Fetch reminders from date range
    /// - Parameters:
    ///   - startDate: start date range
    ///   - endDate: end date range
    ///   - completion: completion handler
    ///   - filterCalendarIDs: filterable Calendar IDs
    /// Returns: events
    public func fetchReminders(start: Date, end: Date, calendars filterCalendarIDs: [String] = [], completion: @escaping (([EKReminder]?) -> ())) async throws {
        let authorization = try await determineReminderStoreAuthorization()
        guard authorization == .authorized else {
            throw EventError.eventAuthorizationStatus(authorization)
        }
        let calendars = self.eventStore.calendars(for: .reminder).filter { calendar in
            if filterCalendarIDs.isEmpty { return true }
            return filterCalendarIDs.contains(calendar.calendarIdentifier)
        }
        let predicate = self.eventStore.predicateForReminders(in: calendars)
        self.eventStore.fetchReminders(matching: predicate, completion: completion)
    }
    
    /// Request event store authorization for Events
    /// - Returns: EKAuthorizationStatus enum
    public func determineEventStoreAuthorization() async throws -> EKAuthorizationStatus {
        let currentAuthStatus = EKEventStore.authorizationStatus(for: .event)
        if currentAuthStatus == .notDetermined || currentAuthStatus == .denied {
            if try await requestEventAccess() {
                self.eventStore = EKEventStore()
                return EKEventStore.authorizationStatus(for: .event)
            } else {
                throw EventError.unableToAccessCalendar
            }
        } else if currentAuthStatus == .restricted {
            throw EventError.unableToAccessCalendar
        } else {
            return currentAuthStatus
        }
    }
    
    /// Request event store authorization for Reminders
    /// - Returns: EKAuthorizationStatus enum
    public func determineReminderStoreAuthorization() async throws -> EKAuthorizationStatus {
        let currentAuthStatus = EKEventStore.authorizationStatus(for: .reminder)
        if currentAuthStatus == .notDetermined || currentAuthStatus == .denied {
            if try await requestReminderAccess() {
                self.eventStore = EKEventStore()
                return EKEventStore.authorizationStatus(for: .reminder)
            } else {
                throw EventError.unableToAccessCalendar
            }
        } else if currentAuthStatus == .restricted {
            throw EventError.unableToAccessCalendar
        } else {
            return currentAuthStatus
        }
    }
    
    private func requestEventAccess() async throws -> Bool {
        let accessGranted = try await eventStore.requestAccess(to: .event)
        eventStore = EKEventStore()
        return accessGranted
    }
    
    private func requestReminderAccess() async throws -> Bool {
        let accessGranted = try await eventStore.requestAccess(to: .reminder)
        eventStore = EKEventStore()
        return accessGranted
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
        startDate: Date,
        endDate: Date?,
        span: EKSpan = .thisEvent,
        isAllDay: Bool = false
    ) async throws -> EKEvent {
        let calendar = try await accessEventsCalendar()
        let createdEvent = try self.eventStore.createEvent(title: title, startDate: startDate, endDate: endDate, calendar: calendar, span: span, isAllDay: isAllDay)
        return createdEvent
    }
    
    /// Create a Reminder
    /// - Parameters:
    ///   - title: title of the reminder
    /// - Returns: created reminder
    public func createReminder(
        _ title: String,
        startDate: DateComponents?,
        dueDate: DateComponents?
    ) async throws -> EKReminder {
        self.eventStore.calendars(for: .reminder)
        let calendar = try await accessRemindersCalendar()
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
    private func accessEventsCalendar() async throws -> EKCalendar {
        let authorization = try await determineEventStoreAuthorization()
        guard authorization == .authorized else {
            throw EventError.eventAuthorizationStatus(authorization)
        }
        guard let calendar = eventStore.calendarForEvents() else {
            throw EventError.unableToAccessCalendar
        }
        return calendar
    }
    /// Request access to Reminders calendar
    /// - Returns: calendar object
    @discardableResult
    private func accessRemindersCalendar() async throws -> EKCalendar {
        let authorization = try await determineReminderStoreAuthorization()
        guard authorization == .authorized else {
            throw EventError.eventAuthorizationStatus(authorization)
        }
        guard let calendar = eventStore.calendarForReminders() else {
            throw EventError.unableToAccessCalendar
        }
        return calendar
    }
}
