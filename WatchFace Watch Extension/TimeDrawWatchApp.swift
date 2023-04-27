//
//  TimeDrawApp.swift
//  WatchFace WatchKit Extension
//
//  Created by Michael Ellis on 6/7/22.
//

import SwiftUI

@main
struct TimeDrawWatchApp: App {
        
    @ObservedObject private var listViewModel: CalendarItemListViewModel = .shared
    @StateObject private var itemViewModel: ModifyCalendarItemViewModel = ModifyCalendarItemViewModel()
    
    init() {
        EventKitManager.configureWithAppName("TimeDraw")
        listViewModel.updateData()
        UIFont.overrideInitialize()
        if AppSettings.shared.userSelectedCalendars == nil || AppSettings.shared.userSelectedCalendars.loadCalendarIds().isEmpty {
            let allCalendars = AppSettings.shared.fetchAllCalendars()
            AppSettings.shared.userSelectedCalendars = allCalendars.compactMap({ $0.calendarIdentifier }).archiveCalendars()
        }
    }
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            TimeDrawClock(width: 70)
                .environmentObject(self.itemViewModel)
                .environmentObject(self.listViewModel)
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
