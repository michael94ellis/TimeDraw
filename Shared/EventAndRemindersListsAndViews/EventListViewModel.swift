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
    // MARK: - Properties
    @Published public var events = [EKEvent]()
    @Published public var reminders = [EKReminder]()
    
    // MARK: Static accessor
    public static let shared = EventListViewModel()
    // This prevents others from using the default '()' initializer for this class.
    private init() {
        self.updateData()
    }
    
    public func updateData() {
        Task {
            try await self.fetchEventsForToday()
            print(self.events)
        }
        Task {
            try await self.fetchRemindersForToday()
            print(self.reminders    )
        }
    }
    
    // MARK: - Fetch Events
    /// Fetch events for today
    /// - Parameter filterCalendarIDs: filterable Calendar IDs
    /// Returns: events for today
    public func fetchEventsForToday(filterCalendarIDs: [String] = []) async throws {
        let today = Date()
        self.events = try await EventKitManager.shared.fetchEvents(startDate: today.startOfDay, endDate: today.endOfDay, filterCalendarIDs: filterCalendarIDs)
    }
    
    // MARK: Fetch Reminders
    /// Fetch events for today
    /// - Parameter filterCalendarIDs: filterable Calendar IDs
    /// Returns: events for today
    public func fetchRemindersForToday() async throws {
        let date = Date()
        try await EventKitManager.shared.fetchReminders(start: date.startOfDay, end: date.endOfDay, completion: { reminders in
            // MainActor didnt work for callback
            DispatchQueue.main.async {
                self.reminders = reminders ?? []
            }
        })
    }
}
