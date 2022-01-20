//
//  EKEventStore-Extension.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/4/22.
//

import Foundation
import EventKit

extension EKEvent: Identifiable { }
extension EKReminder: Identifiable { }

extension EKEventStore {

    // MARK: - CRUD
    /// Create an event
    /// - Parameters:
    ///   - title: title of the event
    ///   - startDate: event's start date
    ///   - endDate: event's end date
    ///   - calendar: calendar instance
    ///   - span: event's span
    ///   - isAllDay: is all day event
    /// - Returns: created event
    public func createEvent(
        title: String,
        startDate: Date,
        endDate: Date?,
        calendar: EKCalendar,
        span: EKSpan = .thisEvent,
        isAllDay: Bool = false
    ) throws -> EKEvent {
        let event = EKEvent(eventStore: self)
        event.calendar = calendar
        event.title = title
        event.isAllDay = isAllDay
        event.startDate = startDate
        event.endDate = endDate
        try save(event, span: span, commit: true)
        return event
    }
    /// Create a Reminder
    /// - Parameters:
    ///   - title: title of the event
    ///   - calendar: calendar instance
    /// - Returns: created event
    public func createReminder(
        title: String,
        startDate: Date,
        endDate: Date?,
        calendar: EKCalendar,
        span: EKSpan = .thisEvent,
        isAllDay: Bool = false
    ) throws -> EKReminder {
        let reminder = EKReminder(eventStore: self)
        reminder.calendar = calendar
        reminder.title = title
        try save(reminder, commit: true)
        return reminder
    }
    
    /// Delete event
    /// - Parameters:
    ///   - identifier: event identifier
    ///   - span: event's span
    public func deleteEvent(
        identifier: String,
        span: EKSpan = .thisEvent
    ) throws {
        guard let event = fetchEvent(identifier: identifier) else {
            throw EventError.invalidEvent
        }

        try remove(event, span: span, commit: true)
    }
    
    /// Delete event
    /// - Parameters:
    ///   - identifier: event identifier
    ///   - span: event's span
    public func deleteReminder(
        identifier: String,
        span: EKSpan = .thisEvent
    ) throws {
        guard let event = fetchEvent(identifier: identifier) else {
            throw EventError.invalidEvent
        }

        try remove(event, span: span, commit: true)
    }

    // MARK: - Fetch
    /// Calendar for current AppName
    /// - Returns: App calendar
    /// - Parameter calendarColor: default new calendar color
    public func calendarForApp(calendarColor: CGColor = .init(red: 1, green: 0, blue: 0, alpha: 1)) -> EKCalendar? {
        guard let appName = EventManager.appName else {
            print("App name is nil, please config with `Shift.configureWithAppName` in AppDelegate")
            return nil
        }

        let calendars = self.calendars(for: .event)

        if let clendar = calendars.first(where: { $0.title == appName }) {
            return clendar
        } else {
            let newClendar = EKCalendar(for: .event, eventStore: self)
            newClendar.title = appName
            newClendar.source = defaultCalendarForNewEvents?.source
            newClendar.cgColor = .init(red: 1, green: 0, blue: 0, alpha: 1)
            try? saveCalendar(newClendar, commit: true)
            return newClendar
        }
    }

    /// Fetch an EKEvent instance with given identifier
    /// - Parameter identifier: event identifier
    /// - Returns: an EKEvent instance with given identifier
    func fetchEvent(identifier: String) -> EKEvent? {
        event(withIdentifier: identifier)
    }
    /// Fetch an EKEvent instance with given identifier
    /// - Parameter identifier: event identifier
    /// - Returns: an EKEvent instance with given identifier
    func getReminders(matching predicate: NSPredicate?, completion: @escaping ([EKReminder]?) -> Void) {
        let reminderPredicate: NSPredicate = predicate ?? self.predicateForReminders(in: nil)
        self.fetchReminders(matching: reminderPredicate, completion: completion)
    }
}
