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
    static let showEmojiButton = "showEmojiButton"
    /// Bool
    static let isDailyGoalEnabled = "isDailyGoalEnabled"
    /// Bool
    static let isTimeDrawClockEnabled = "isTimeDrawClockEnabled"
    /// ItemRecurrenceType
    static let showItemRecurrenceType = "showItemRecurrenceType"
    /// CalendarItemType
    static let showCalendarItemType = "showCalendarItemType"
    /// Bool
    static let showListIcons = "showListIcons"
    /// Bool
    static let showCalendarPickerButton = "showCalendarPickerButton"
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
    
    init() { }
}
