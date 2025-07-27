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
                #if DEBUG
                    .onAppear {
                        // Only use mock data if no real events are found
                        if listViewModel.events.isEmpty && listViewModel.reminders.isEmpty {
                            print("Watch: No real events found, using mock data for testing")
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
                        } else {
                            print("Watch: Found \(listViewModel.events.count) events and \(listViewModel.reminders.count) reminders")
                        }
                    }
                #endif
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
