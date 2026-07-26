//
//  TimeDrawApp.swift
//  Shared
//
//  Created by Michael Ellis on 1/2/22.
//

import DesignToken
import EventInput
import AppCore
import SwiftUI
import EventKit
import EventManagement

@main
struct TimeDrawApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var appSettings: AppSettings = .init()
    @StateObject private var listViewModel: CalendarListViewModel = .init()
    @StateObject private var itemViewModel: ModifyCalendarItemViewModel = .init()
    
    init() {
        DesignTokenFonts.register()
        UIFont.overrideInitialize()
        PhoneWatchSync.shared.activate()
        UserDefaults.standard.register(defaults: [
            AppStorageKey.isDailyGoalEnabled: false,
            AppStorageKey.timePickerGranularity: 15,
            AppStorageKey.showCalendarItemType: CalendarItemType.all.rawValue,
            AppStorageKey.showItemRecurrenceType: ItemRecurrenceType.all.rawValue,
        ])
    }
    
    private func syncPreferencesToWatch() {
        PhoneWatchSync.shared.syncSelectedCalendars(
            appSettings.userSelectedCalendars.loadCalendarIds()
        )
        PhoneWatchSync.shared.syncHighlightColor(appSettings.highlightColorHex)
    }
    
    var body: some Scene {
        WindowGroup {
            MainViewContainer()
                .adaptiveLayoutMetrics()
                .environmentObject(itemViewModel)
                .environmentObject(listViewModel)
                .environmentObject(appSettings)
                .onAppear {
                    syncPreferencesToWatch()
                }
                .onChange(of: appSettings.userSelectedCalendars) { _, _ in
                    syncPreferencesToWatch()
                }
                .onChange(of: appSettings.highlightColorHex) { _, hex in
                    PhoneWatchSync.shared.syncHighlightColor(hex)
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        listViewModel.updateData()
                        syncPreferencesToWatch()
                    }
                }
        }
    }
}
