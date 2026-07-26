//
//  WatchCalendarModel.swift
//  WatchFace
//

import AppCore
import EventKit
import SwiftUI

/// Watch-specific calendar loader. Avoids shared AppStorage filters / Dependency wiring
/// that have been unreliable for EventKit on watchOS. Calendar IDs are mirrored from
/// the iPhone via `PhoneWatchSync` / `MirroredCalendarSelection`.
@Observable
@MainActor
final class WatchCalendarModel {
    
    @ObservationIgnored
    private var store = EKEventStore()
    
    private(set) var events: [EKEvent] = []
    private(set) var reminders: [EKReminder] = []
    
    @ObservationIgnored
    private var eventStatus: EKAuthorizationStatus { EKEventStore.authorizationStatus(for: .event) }
    @ObservationIgnored
    private var reminderStatus: EKAuthorizationStatus { EKEventStore.authorizationStatus(for: .reminder) }
    
    @ObservationIgnored
    var isEventAccessGranted: Bool { eventStatus == .fullAccess }
    @ObservationIgnored
    var isReminderAccessGranted: Bool { reminderStatus == .fullAccess }
    
    /// Timed reminders for today only.
    @ObservationIgnored
    var todaysReminders: [EKReminder] {
        let day = Date()
        let calendar = Calendar.current
        return reminders.filter { reminder in
            if let due = reminder.dueDateComponents, let date = calendar.date(from: due) {
                return calendar.isDate(date, inSameDayAs: day)
            }
            if let start = reminder.startDateComponents, let date = calendar.date(from: start) {
                return calendar.isDate(date, inSameDayAs: day)
            }
            return false
        }
    }
    
    @discardableResult
    func requestEventAccess() async -> Bool {
        do {
            let granted = try await store.requestFullAccessToEvents()
            if granted {
                store = EKEventStore()
                await load()
            }
            return granted
        } catch {
            return false
        }
    }
    
    @discardableResult
    func requestReminderAccess() async -> Bool {
        do {
            let granted = try await store.requestFullAccessToReminders()
            if granted {
                store = EKEventStore()
                await load()
            }
            return granted
        } catch {
            return false
        }
    }
    
    func load(calendarIDs: [String]? = nil) async {
        store = EKEventStore()
        let filterIDs = calendarIDs ?? MirroredCalendarSelection.shared.selectedCalendarIDs
        
        if eventStatus == .fullAccess {
            let calendars = Self.resolvedCalendars(
                in: store,
                for: .event,
                filterCalendarIDs: filterIDs
            )
            let predicate = store.predicateForEvents(
                withStart: Date().startOfDay,
                end: Date().endOfDay,
                calendars: calendars
            )
            events = store.events(matching: predicate)
        } else {
            events = []
        }
        
        if reminderStatus == .fullAccess {
            let calendars = Self.resolvedCalendars(
                in: store,
                for: .reminder,
                filterCalendarIDs: filterIDs
            )
            let predicate = store.predicateForReminders(in: calendars)
            let fetched = await withCheckedContinuation { continuation in
                store.fetchReminders(matching: predicate) { reminders in
                    continuation.resume(returning: reminders ?? [])
                }
            }
            reminders = fetched.filter { !$0.isCompleted }
        } else {
            reminders = []
        }
    }
    
    /// `nil` means “all calendars”. Matches `EventKitManager.resolvedCalendars`.
    private static func resolvedCalendars(
        in store: EKEventStore,
        for entityType: EKEntityType,
        filterCalendarIDs: [String]
    ) -> [EKCalendar]? {
        guard !filterCalendarIDs.isEmpty else { return nil }
        let filtered = store.calendars(for: entityType).filter {
            filterCalendarIDs.contains($0.calendarIdentifier)
        }
        return filtered.isEmpty ? nil : filtered
    }
}
