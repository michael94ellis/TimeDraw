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
    
    private(set) var events: [EKEvent] = []
    private(set) var reminders: [EKReminder] = []
    private var eventStatus: EKAuthorizationStatus { EKEventStore.authorizationStatus(for: .event) }
    private var reminderStatus: EKAuthorizationStatus { EKEventStore.authorizationStatus(for: .reminder) }
    private(set) var statusMessage: String = ""
    
    @ObservationIgnored
    private var store = EKEventStore()
    
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
            } else {
                statusMessage = "Events denied"
            }
            return granted
        } catch {
            statusMessage = "Events error: \(error.localizedDescription)"
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
            } else {
                statusMessage = "Reminders denied"
            }
            return granted
        } catch {
            statusMessage = "Reminders error: \(error.localizedDescription)"
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
        
        #if DEBUG
        func authLabel(_ status: EKAuthorizationStatus) -> String {
            switch status {
            case .fullAccess: return "ok"
            case .writeOnly: return "write"
            case .denied: return "denied"
            case .restricted: return "restrict"
            case .notDetermined: return "ask"
            @unknown default: return "\(status.rawValue)"
            }
        }
        
        let eventLabel = authLabel(eventStatus)
        let reminderLabel = authLabel(reminderStatus)
        statusMessage = "E:\(events.count) (\(eventLabel))  R:\(todaysReminders.count) (\(reminderLabel))"
        #endif
    }
}
