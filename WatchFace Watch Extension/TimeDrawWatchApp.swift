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
    @StateObject private var itemViewModel: ModifyCalendarItemViewModel = .init()
    @StateObject private var appSettings: AppSettings = .init()
    
    init() {
        UIFont.overrideInitialize()
    }
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            VStack(spacing: 0) {
                Spacer()
                GeometryReader { geo in
                    TimeDrawClock(width: geo.size.width)
                        .environmentObject(self.itemViewModel)
                        .environmentObject(self.listViewModel)
                }
                Spacer()
            }
            .border(.red)
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
