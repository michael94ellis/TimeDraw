//
//  EventListViewModel.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/5/22.
//

import SwiftUI
import EventKit

@MainActor
class EventListViewModel: ObservableObject {
    
    @Published public var displayDate: Date = Date() {
        didSet {
            self.updateData()
        }
    }
    
    @Published public var events: [EKEvent] = []
    @Published public var reminders: [EKReminder] = []
    
    // MARK: Static accessor
    public static let shared = EventListViewModel()
    // This prevents others from using the default '()' initializer for this class.
    private init() {
        self.updateData()
    }
    
    public func updateData() {
        Task {
            try await self.fetchEventsForDisplayDate()
        }
        Task {
            try await self.fetchRemindersForDisplayDate()
        }
    }
    
    // MARK: - Fetch Events
    /// Fetch events for today
    /// - Parameter filterCalendarIDs: filterable Calendar IDs
    /// Returns: events for today
    public func fetchEventsForDisplayDate(filterCalendarIDs: [String] = []) async throws {
        self.events = try await EventKitManager.shared.fetchEvents(startDate: self.displayDate.startOfDay, endDate: self.displayDate.endOfDay, filterCalendarIDs: filterCalendarIDs)
    }
    
    // MARK: Fetch Reminders
    /// Fetch events for today
    /// - Parameter filterCalendarIDs: filterable Calendar IDs
    /// Returns: events for today
    public func fetchRemindersForDisplayDate() async throws {
        try await EventKitManager.shared.fetchReminders(start: self.displayDate.startOfDay, end: self.displayDate.endOfDay, completion: { reminders in
            // MainActor didnt work for callback
            DispatchQueue.main.async {
                self.reminders = reminders ?? []
            }
        })
    }
}
