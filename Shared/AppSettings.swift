//
//  AppSettings.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/13/22.
//

import SwiftUI
import EventKit

class AppSettings: ObservableObject {
    
    @AppStorage("first_open") var isFirstAppOpen = true
    @AppStorage("showEmojiButton") var showEmojiButton: Bool = true

    @AppStorage("isDailyGoalEnabled") var isDailyGoalEnabled: Bool = false
    @AppStorage("isTimeDrawClockEnabled") var isTimeDrawClockEnabled: Bool = true
    @AppStorage("showItemRecurrenceType") var showItemRecurrenceType: ItemRecurrenceType = .all
    @AppStorage("showCalendarItemType") var showCalendarItemType: CalendarItemType = .all
    @AppStorage("showListIcons") var showListIcons: Bool = true
    @AppStorage("showCalendarPickerButton") var showCalendarPickerButton: Bool = true
    @AppStorage("userSelectedCalendars") var userSelectedCalendars: Data?
    @AppStorage("currentSelectedCalendar") var currentSelectedCalendar: Data?
    /// 1, 2, 3, 5, 10, 12, 15, 20, 30 divisors of 60
    @AppStorage("timePickerGranularity") var timePickerGranularity: Int = 15
    
    @AppStorage("showRecurringItems") var showRecurringItems: Bool = true
    @AppStorage("noteLineLimit") var noteLineLimit: Int = 3
    static let shared = AppSettings()
    
    private init() { }
    
    @discardableResult
    func fetchAllCalendars() -> [EKCalendar] {
        var calendars = EventKitManager.shared.eventStore.calendars(for: .event)
        calendars.append(contentsOf: EventKitManager.shared.eventStore.calendars(for: .reminder))
        return calendars
    }
}
