//
//  TimeDrawApp.swift
//  WatchFace WatchKit Extension
//
//  Created by Michael Ellis on 6/7/22.
//

import EventKit
import SwiftUI

@main
struct TimeDrawWatchApp: App {
        
    @StateObject private var listViewModel: CalendarItemListViewModel = .init()
    
    init() {
        UIFont.overrideInitialize()
    }
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            VStack(spacing: 0) {
                Spacer()
                TimeDrawClock(events: listViewModel.events, reminders: listViewModel.reminders)
                    .environmentObject(self.listViewModel)
                .onReceive(Timer.publish(every: 300, on: .main, in: .common).autoconnect()) { _ in
                    // Refresh data every 5 minutes
                    listViewModel.updateData()
                }
                Spacer()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
