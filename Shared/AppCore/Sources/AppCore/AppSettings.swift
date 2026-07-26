//
//  AppSettings.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/13/22.
//

import EventManagement
import SwiftUI

public enum AppStorageKey {
    /// Bool
    public static let firstOpen = "first_open"
    /// Bool
    public static let isDailyGoalEnabled = "isDailyGoalEnabled"
    /// ItemRecurrenceType
    public static let showItemRecurrenceType = EventStorageKey.showItemRecurrenceType
    /// CalendarItemType
    public static let showCalendarItemType = EventStorageKey.showCalendarItemType
    /// Data?
    public static let userSelectedCalendars = EventStorageKey.userSelectedCalendars
    /// Data?
    public static let currentSelectedCalendar = EventStorageKey.currentSelectedCalendar
    /// Int
    public static let timePickerGranularity = "timePickerGranularity"
    /// Bool
    public static let showRecurringItems = EventStorageKey.showRecurringItems
    /// String — sRGB hex (e.g. "FF5C39") for header year, today text, and clock hands
    public static let highlightColorHex = "highlightColorHex"
}

public class AppSettings: ObservableObject {

    /// Default matches `Colors.today` / `Palette.red1`.
    public static let defaultHighlightColorHex = "FF5C39"
    
    @AppStorage(AppStorageKey.firstOpen) public var isFirstAppOpen = true

    @AppStorage(AppStorageKey.isDailyGoalEnabled) public var isDailyGoalEnabled: Bool = false
    @AppStorage(AppStorageKey.showItemRecurrenceType) public var showItemRecurrenceType: ItemRecurrenceType = .all
    @AppStorage(AppStorageKey.showCalendarItemType) public var showCalendarItemType: CalendarItemType = .all
    @AppStorage(AppStorageKey.userSelectedCalendars) public var userSelectedCalendars: Data?
    @AppStorage(AppStorageKey.currentSelectedCalendar) public var currentSelectedCalendar: Data?
    /// 1, 2, 3, 5, 10, 12, 15, 20, 30 divisors of 60
    @AppStorage(AppStorageKey.timePickerGranularity) public var timePickerGranularity: Int = 15
    
    @AppStorage(AppStorageKey.showRecurringItems) public var showRecurringItems: Bool = true

    @AppStorage(AppStorageKey.highlightColorHex, store: .appGroup)
    public var highlightColorHex: String = AppSettings.defaultHighlightColorHex
    
    public init() {
        Self.migrateHighlightColorIfNeeded()
    }

    /// Copies a previously saved highlight color from standard defaults into the app group suite.
    private static func migrateHighlightColorIfNeeded() {
        let group = UserDefaults.appGroup
        guard group.object(forKey: AppStorageKey.highlightColorHex) == nil,
              let legacy = UserDefaults.standard.string(forKey: AppStorageKey.highlightColorHex)
        else { return }
        group.set(legacy, forKey: AppStorageKey.highlightColorHex)
    }
}
