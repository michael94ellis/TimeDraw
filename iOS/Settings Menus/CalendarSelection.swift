//
//  CalendarSelection.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/12/22.
//

import Dependencies
import AppCore
import EventKit
import EventUIComponents
import SwiftUI

struct CalendarSelection: View {
    
    enum EntityTypeState {
        case loading
        case notDetermined
        case authorized(calendars: [EKCalendar])
        case denied
    }

    var selectedIds: [String] { appSettings.userSelectedCalendars.loadCalendarIds() }
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.scenePhase) private var scenePhase
    @Dependency(\.eventKitManager) private var eventKitManager

    @State private var eventAuthStatus: EntityTypeState = .loading
    @State private var reminderAuthStatus: EntityTypeState = .loading
    
    func loadCalendars() async {
        switch eventKitManager.eventAuthorizationStatus() {
        case .denied, .writeOnly, .restricted:
            eventAuthStatus = .denied
        case .fullAccess:
            let calendars = await eventKitManager.eventStore.calendars(for: .event)
            eventAuthStatus = .authorized(calendars: calendars)
        default:
            eventAuthStatus = .notDetermined
        }
        switch eventKitManager.reminderAuthorizationStatus() {
        case .denied, .writeOnly, .restricted:
            reminderAuthStatus = .denied
        case .fullAccess:
            let calendars = await eventKitManager.eventStore.calendars(for: .reminder)
            reminderAuthStatus = .authorized(calendars: calendars)
        default:
            reminderAuthStatus = .notDetermined
        }
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
                switch eventAuthStatus {
                case .loading:
                    ProgressView()
                case .authorized(let calendars):
                    selectionList(of: calendars)
                case .denied, .notDetermined:
                    EventKitPermissionPlaceholder(
                        message: "Allow calendar access to choose which event calendars appear in TimeDraw.",
                        authorizationStatus: eventKitManager.eventAuthorizationStatus(),
                        requestAccess: {
                            (try? await eventKitManager.requestEventAccess()) ?? false                        }
                    )
                }
            }
            Section("Reminders") {
                switch reminderAuthStatus {
                case .loading:
                    ProgressView()
                case .authorized(let calendars):
                    selectionList(of: calendars)
                case .denied, .notDetermined:
                    EventKitPermissionPlaceholder(
                        message: "Allow reminders access to choose which reminder lists appear in TimeDraw.",
                        authorizationStatus: eventKitManager.reminderAuthorizationStatus(),
                        requestAccess: {
                            (try? await eventKitManager.requestReminderAccess()) ?? false                        }
                    )
                }
            }
        }
        .navigationTitle("Calendars")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await loadCalendars()
            }
        }
    }
}
