//
//  AppSettings.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/13/22.
//

import SwiftUI
import EventKit

enum AppStorageKey {
    /// Bool
    static let firstOpen = "first_open"
    /// Bool
    static let isDailyGoalEnabled = "isDailyGoalEnabled"
    /// ItemRecurrenceType
    static let showItemRecurrenceType = "showItemRecurrenceType"
    /// CalendarItemType
    static let showCalendarItemType = "showCalendarItemType"
    /// Data?
    static let userSelectedCalendars = "userSelectedCalendars"
    /// Data?
    static let currentSelectedCalendar = "currentSelectedCalendar"
    /// Int
    static let timePickerGranularity = "timePickerGranularity"
    /// Bool
    static let showRecurringItems = "showRecurringItems"
}

class AppSettings: ObservableObject {
    
    @AppStorage(AppStorageKey.firstOpen) var isFirstAppOpen = true

    @AppStorage(AppStorageKey.isDailyGoalEnabled) var isDailyGoalEnabled: Bool = false
    @AppStorage(AppStorageKey.showItemRecurrenceType) var showItemRecurrenceType: ItemRecurrenceType = .all
    @AppStorage(AppStorageKey.showCalendarItemType) var showCalendarItemType: CalendarItemType = .all
    @AppStorage(AppStorageKey.userSelectedCalendars) var userSelectedCalendars: Data?
    @AppStorage(AppStorageKey.currentSelectedCalendar) var currentSelectedCalendar: Data?
    /// 1, 2, 3, 5, 10, 12, 15, 20, 30 divisors of 60
    @AppStorage(AppStorageKey.timePickerGranularity) var timePickerGranularity: Int = 15
    
    @AppStorage(AppStorageKey.showRecurringItems) var showRecurringItems: Bool = true
    
    init() { }
}
