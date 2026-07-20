//
//  CalendarSelection.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/12/22.
//

import Dependencies
import EventKit
import EventUIComponents
import SwiftUI

struct CalendarSelection: View {

    var selectedIds: [String] { appSettings.userSelectedCalendars.loadCalendarIds() }
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.scenePhase) private var scenePhase
    @Dependency(\.eventKitManager) private var eventKitManager

    @State private var eventAuthStatus: EKAuthorizationStatus = .notDetermined
    @State private var reminderAuthStatus: EKAuthorizationStatus = .notDetermined

    func refreshAuthStatuses() {
        eventAuthStatus = eventKitManager.eventAuthorizationStatus()
        reminderAuthStatus = eventKitManager.reminderAuthorizationStatus()
    }

    func toggleCalendar(_ calendar: EKCalendar) {
        var newIds = appSettings.userSelectedCalendars.loadCalendarIds()
        if newIds.contains(calendar.calendarIdentifier) {
            newIds.removeAll { $0 == calendar.calendarIdentifier }
        } else {
            newIds.append(calendar.calendarIdentifier)
        }
        appSettings.userSelectedCalendars = newIds.archiveCalendars()
    }

    func selectionList(of calendars: [EKCalendar]) -> some View {
        ForEach(calendars, id: \.calendarIdentifier) { calendar in
            Button {
                toggleCalendar(calendar)
            } label: {
                HStack {
                    Circle()
                        .fill(Color(cgColor: calendar.cgColor))
                        .frame(width: 12, height: 12)
                    Text(calendar.title)
                        .foregroundStyle(Color(uiColor: .label))
                    Spacer()
                    if selectedIds.contains(calendar.calendarIdentifier) {
                        Image(systemName: "checkmark")
                            .foregroundStyle(Color.blue1)
                    }
                }
            }
        }
    }

    var body: some View {
        List {
            Section("Events") {
                if eventKitManager.isEventAccessGranted(eventAuthStatus) {
                    selectionList(of: eventKitManager.eventStore.calendars(for: .event))
                } else {
                    EventKitPermissionPlaceholder(
                        message: "Allow calendar access to choose which event calendars appear in TimeDraw.",
                        authorizationStatus: eventAuthStatus,
                        isAccessGranted: eventKitManager.isEventAccessGranted
                    )
                }
            }
            Section("Reminders") {
                if eventKitManager.isReminderAccessGranted(reminderAuthStatus) {
                    selectionList(of: eventKitManager.eventStore.calendars(for: .reminder))
                } else {
                    EventKitPermissionPlaceholder(
                        message: "Allow reminders access to choose which reminder lists appear in TimeDraw.",
                        authorizationStatus: reminderAuthStatus,
                        isAccessGranted: eventKitManager.isReminderAccessGranted
                    )
                }
            }
        }
        .navigationTitle("Calendars")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            refreshAuthStatuses()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                refreshAuthStatuses()
            }
        }
    }
}
