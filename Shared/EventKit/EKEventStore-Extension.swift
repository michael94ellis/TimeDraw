//
//  EKEventStore-Extension.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/4/22.
//

import Foundation
import EventKit

extension EKRecurrenceFrequency: CaseIterable, CustomStringConvertible {
    public static var allCases: [EKRecurrenceFrequency] { [.daily, .weekly, .monthly, .yearly] }
    public var description: String {
        switch self.rawValue {
        case 0: return "Daily"
        case 1: return "Weekly"
        case 2: return "Monthly"
        case 3: return "Yearly"
        default: return "Unsupported"
        }
    }
}
extension EKEvent: Identifiable { }
extension EKReminder: Identifiable { }
extension EKReminderPriority {
//    static let none = 0
//    static let high = 1
//    static let mediumHigh = 3
//    static let medium = 5
//    static let mediumLow = 7
//    static let low = 9
}
extension EKEventStatus {
//    static let none = 0
//    static let confirmed = 1
//    static let tentative = 2
//    static let cancelled = 3
}
extension EKEventAvailability {
//    static let notSupported = -1
//    static let busy = 0
//    static let free = 1
//    static let tentative = 2
//    static let unavailable = 3
}

extension EKEventStore {
    
    /// Fetch an EKEvent instance with given identifier
    /// - Parameter identifier: event identifier
    /// - Returns: an EKEvent instance with given identifier
    func fetchEvent(identifier: String) -> EKEvent? {
        self.event(withIdentifier: identifier)
    }
    
    /// Fetch an EKEvent instance with given identifier
    /// - Parameter identifier: event identifier
    /// - Returns: an EKEvent instance with given identifier
    func fetchReminder(identifier: String) -> EKReminder? {
        self.calendarItem(withIdentifier: identifier) as? EKReminder
    }
    /// Fetch an EKEvent instance with given identifier
    /// - Returns: All EKReminders that are incomplete
    func getIncompleteReminders(completion: @escaping ([EKReminder]?) -> Void) {
        let reminderPredicate: NSPredicate = self.predicateForIncompleteReminders(withDueDateStarting: nil, ending: nil, calendars: nil)
        self.fetchReminders(matching: reminderPredicate, completion: completion)
    }
    
    // MARK: - Non Watch Functions
    // Watch OS does not support these actions
    // https://developer.apple.com/forums/thread/42293
    #if !os(watchOS)
    // MARK: - Create
    
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
        startDate: DateComponents?,
        dueDate: DateComponents?,
        calendar: EKCalendar
    ) throws -> EKReminder {
        let reminder = EKReminder(eventStore: self)
        reminder.title = title
        reminder.calendar = calendar
        if let startDate = startDate {
            reminder.startDateComponents = startDate
        }
        if let dueDate = dueDate {
            reminder.dueDateComponents = dueDate
        }
        try save(reminder, commit: true)
        return reminder
    }
    
    // MARK: - Delete
    
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
        identifier: String
    ) throws {
        guard let reminder = self.fetchReminder(identifier: identifier) else {
            throw EventError.invalidEvent
        }
        try? self.remove(reminder, commit: true)
    }

    // MARK: - Fetch
    /// Event Calendar for current AppName
    /// - Returns: App calendar for EKEvents
    /// - Parameter calendarColor: default new calendar color
    public func calendarForEvents(calendarColor: CGColor = .init(red: 1, green: 0, blue: 0, alpha: 1)) -> EKCalendar? {
        guard let appName = EventKitManager.appName else {
            print("App name is nil, please config with `Shift.configureWithAppName` in AppDelegate")
            return nil
        }

        let calendars = self.calendars(for: .event)

        if let appCalendar = calendars.first(where: { $0.title == appName }) {
            return appCalendar
        } else {
            let newCalendar = EKCalendar(for: .event, eventStore: self)
            newCalendar.title = appName
            newCalendar.source = defaultCalendarForNewEvents?.source
            newCalendar.cgColor = .init(red: 1, green: 0, blue: 0, alpha: 1)
            try? saveCalendar(newCalendar, commit: true)
            return newCalendar
        }
    }
    /// Reminder Calendar for current AppName
    /// - Returns: App calendar for EKReminders
    /// - Parameter calendarColor: default new calendar color
    public func calendarForReminders(calendarColor: CGColor = .init(red: 12, green: 22, blue: 0, alpha: 1)) -> EKCalendar? {
        guard let appName = EventKitManager.appName else {
            print("App name is nil, please config with `Shift.configureWithAppName` in AppDelegate")
            return nil
        }

        let calendars = self.calendars(for: .reminder)

        if let appCalendar = calendars.first(where: { $0.title == appName }) {
            return appCalendar
        } else {
            let newCalendar = EKCalendar(for: .reminder, eventStore: self)
            newCalendar.title = appName
            newCalendar.source = self.defaultCalendarForNewEvents?.source
            newCalendar.cgColor = .init(red: 1, green: 0, blue: 0, alpha: 1)
            try? self.saveCalendar(newCalendar, commit: true)
            return newCalendar
        }
    }
    #endif
}
