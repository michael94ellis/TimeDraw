//
//  AppSettings.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/13/22.
//

import SwiftUI
import EventKit

public enum AppStorageKey {
    /// Bool
    public static let firstOpen = "first_open"
    /// Bool
    public static let isDailyGoalEnabled = "isDailyGoalEnabled"
    /// ItemRecurrenceType
    public static let showItemRecurrenceType = "showItemRecurrenceType"
    /// CalendarItemType
    public static let showCalendarItemType = "showCalendarItemType"
    /// Data?
    public static let userSelectedCalendars = "userSelectedCalendars"
    /// Data?
    public static let currentSelectedCalendar = "currentSelectedCalendar"
    /// Int
    public static let timePickerGranularity = "timePickerGranularity"
    /// Bool
    public static let showRecurringItems = "showRecurringItems"
}

public class AppSettings: ObservableObject {
    
    @AppStorage(AppStorageKey.firstOpen) public var isFirstAppOpen = true

    @AppStorage(AppStorageKey.isDailyGoalEnabled) public var isDailyGoalEnabled: Bool = false
    @AppStorage(AppStorageKey.showItemRecurrenceType) public var showItemRecurrenceType: ItemRecurrenceType = .all
    @AppStorage(AppStorageKey.showCalendarItemType) public var showCalendarItemType: CalendarItemType = .all
    @AppStorage(AppStorageKey.userSelectedCalendars) public var userSelectedCalendars: Data?
    @AppStorage(AppStorageKey.currentSelectedCalendar) public var currentSelectedCalendar: Data?
    /// 1, 2, 3, 5, 10, 12, 15, 20, 30 divisors of 60
    @AppStorage(AppStorageKey.timePickerGranularity) public var timePickerGranularity: Int = 15
    
    @AppStorage(AppStorageKey.showRecurringItems) public var showRecurringItems: Bool = true
    
    public init() { }
}
