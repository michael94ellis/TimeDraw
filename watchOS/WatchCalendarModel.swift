//
//  WatchCalendarModel.swift
//  WatchFace
//

import AppCore
import EventKit
import SwiftUI

/// Watch-specific calendar loader. Avoids shared AppStorage filters / Dependency wiring
/// that have been unreliable for EventKit on watchOS.
@Observable
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
            }
            if granted {
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
            }
            if granted {
                await load()
            }
            return granted
        } catch {
            return false
        }
    }
    
    func load() async {
        store = EKEventStore()
        
        var loadedEvents: [EKEvent] = []
        var loadedReminders: [EKReminder] = []
        await withTaskGroup { group in
            group.addTask {
                guard self.eventStatus == .fullAccess else {
                    return
                }
                if self.isEventAccessGranted {
                    let start = Date().startOfDay
                    let end = Date().endOfDay
                    let predicate = self.store.predicateForEvents(withStart: start, end: end, calendars: nil)
                    loadedEvents = self.store.events(matching: predicate)
                    self.events = loadedEvents
                }
            }
            group.addTask {
                guard self.reminderStatus == .fullAccess else {
                    return
                }
                if self.isReminderAccessGranted {
                    let predicate = self.store.predicateForReminders(in: nil)
                    loadedReminders = await withCheckedContinuation { continuation in
                        self.store.fetchReminders(matching: predicate) { reminders in
                            continuation.resume(returning: reminders ?? [])
                        }
                    }.filter { !$0.isCompleted }
                    self.reminders = loadedReminders
                }
            }
        }
    }
}
