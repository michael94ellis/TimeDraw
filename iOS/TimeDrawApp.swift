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

@main
struct TimeDrawApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var appSettings: AppSettings = .init()
    @StateObject private var listViewModel: CalendarItemListViewModel = .init()
    @StateObject private var itemViewModel: ModifyCalendarItemViewModel = .init()
    
    init() {
        DesignTokenFonts.register()
        UIFont.overrideInitialize()
        UserDefaults.standard.register(defaults: [
            AppStorageKey.isDailyGoalEnabled: false,
            AppStorageKey.timePickerGranularity: 15,
            AppStorageKey.showCalendarItemType: CalendarItemType.all.rawValue,
            AppStorageKey.showItemRecurrenceType: ItemRecurrenceType.all.rawValue,
        ])
    }
    
    var body: some Scene {
        WindowGroup {
            MainViewContainer()
                .adaptiveLayoutMetrics()
                .environmentObject(itemViewModel)
                .environmentObject(listViewModel)
                .environmentObject(appSettings)
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        listViewModel.updateData()
                    }
                }
        }
    }
}
