//
//  TimeDrawApp.swift
//  WatchFace WatchKit Extension
//
//  Created by Michael Ellis on 6/7/22.
//

import DesignToken
import AppCore
import EventKit
import SwiftUI

@main
struct TimeDrawWatchApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var calendarModel = WatchCalendarModel()
    private let mirroredSelection = MirroredCalendarSelection.shared
    private let mirroredHighlight = MirroredHighlightColor.shared
    
    init() {
        DesignTokenFonts.register()
        UIFont.overrideInitialize()
        PhoneWatchSync.shared.activate()
    }
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            VStack(spacing: 4) {
                Spacer(minLength: 0)
                TimeDrawClock(
                    events: calendarModel.events,
                    reminders: calendarModel.todaysReminders,
                    highlightColorHex: mirroredHighlight.hex
                )
                .adaptiveLayoutMetrics()
                .id(
                    calendarModel.events.compactMap(\.eventIdentifier).joined(separator: "|")
                    + "|\(calendarModel.todaysReminders.count)"
                    + "|\(mirroredSelection.selectedCalendarIDs.joined(separator: ","))"
                    + "|\(mirroredHighlight.hex)"
                )
                
                WatchEventKitAccessIndicators(
                    isEventAccessGranted: calendarModel.isEventAccessGranted,
                    isReminderAccessGranted: calendarModel.isReminderAccessGranted,
                    requestEventAccess: {
                        await calendarModel.requestEventAccess()
                    },
                    requestReminderAccess: {
                        await calendarModel.requestReminderAccess()
                    }
                )
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 4)
            .task {
                await calendarModel.load()
            }
            .onChange(of: mirroredSelection.selectedCalendarIDs) { _, ids in
                Task { await calendarModel.load(calendarIDs: ids) }
            }
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active else { return }
                Task { await calendarModel.load() }
            }
            .onReceive(NotificationCenter.default.publisher(for: .EKEventStoreChanged)) { _ in
                Task { await calendarModel.load() }
            }
            .onReceive(Timer.publish(every: 300, on: .main, in: .common).autoconnect()) { _ in
                Task { await calendarModel.load() }
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
