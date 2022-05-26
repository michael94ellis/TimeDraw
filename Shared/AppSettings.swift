//
//  AppSettings.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/13/22.
//

import SwiftUI
import EventKit

class AppSettings: ObservableObject {
    @AppStorage("isDailyGoalEnabled") var isDailyGoalEnabled: Bool = true
    @AppStorage("isTimeDrawClockEnabled") var isTimeDrawClockEnabled: Bool = true
    @AppStorage("showItemRecurrenceType") var showItemRecurrenceType: ItemRecurrenceType = .all
    @AppStorage("showCalendarItemType") var showCalendarItemType: CalendarItemType = .scheduled
    @AppStorage("showListIcons") var showListIcons: Bool = true
    @AppStorage("showCalendarPickerButton") var showCalendarPickerButton: Bool = true
    @AppStorage("userSelectedCalendars") var userSelectedCalendars: Data?
    @AppStorage("currentSelectedCalendar") var currentSelectedCalendar: Data?
    /// 1, 2, 3, 5, 10, 12, 15, 20, 30 divisors of 60
    @AppStorage("timePickerGranularity") var timePickerGranularity: Int = 15
    
    @AppStorage("showRecurringItems") var showRecurringItems: Bool = true
    @AppStorage("showNotes") var showNotes: Bool = false
    @AppStorage("noteLineLimit") var noteLineLimit: Int = 3
    static let shared = AppSettings()
    
    private init() { }
    
    var allCalendars: [EKCalendar] = []
    
    @discardableResult
    func fetchAllCalendars() -> [EKCalendar] {
        var calendars = EventKitManager.shared.eventStore.calendars(for: .event)
        calendars.append(contentsOf: EventKitManager.shared.eventStore.calendars(for: .reminder))
        self.allCalendars = calendars
        return self.allCalendars
    }
}
enum CalendarItemType: Int, CaseIterable {
    case scheduled = 0
    case unscheduled = 1
    case all = 2
    
    var displayName: String {
        switch(self) {
        case .scheduled: return "Scheduled"
        case .unscheduled: return "Unscheduled"
        case .all: return "All"
        }
    }
}
enum ItemRecurrenceType: Int, CaseIterable {
    case recurring = 0
    case nonRecurring = 1
    case all = 2
    
    var displayName: String {
        switch(self) {
        case .recurring: return "Recurring"
        case .nonRecurring: return "Non Recurring"
        case .all: return "All"
        }
    }
}
