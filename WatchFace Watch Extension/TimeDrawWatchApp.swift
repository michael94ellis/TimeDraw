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
    #if !os(watchOS)
    @StateObject private var itemViewModel: ModifyCalendarItemViewModel = .init()
    #endif
    @StateObject private var appSettings: AppSettings = .init()
    
    init() {
        UIFont.overrideInitialize()
    }
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            VStack(spacing: 0) {
                Spacer()
                TimeDrawClock(events: listViewModel.events, reminders: listViewModel.reminders)
                #if !os(watchOS)
                    .environmentObject(self.itemViewModel)
                #endif
                    .environmentObject(self.listViewModel)
                #if DEBUG
                    .onAppear {
                        listViewModel.events = [
                            .mock(startHour: 6, endHour: 8, color: .blue),
                            .mock(startHour: 10, endHour: 1, color: .green),
                            .mock(startHour: 16, endHour: 22, color: .red)
                        ]
                        listViewModel.reminders = [
                            .mock(startHour: nil, endHour: nil, color: .yellow),
                            .mock(startHour: 1, endHour: nil, color: .purple),
                            .mock(startHour: 1, endHour: 2, color: .cyan)
                        ]
                    }
                #endif
                Spacer()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
