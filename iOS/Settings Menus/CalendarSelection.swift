//
//  CalendarSelection.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/12/22.
//

import Dependencies
import EventKit
import SwiftUI

struct CalendarSelection: View {

    var selectedIds: [String] { appSettings.userSelectedCalendars.loadCalendarIds() }
    @EnvironmentObject var appSettings: AppSettings
    @Dependency(\.eventKitManager) private var eventKitManager

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
                selectionList(of: eventKitManager.eventStore.calendars(for: .event))
            }
            Section("Reminders") {
                selectionList(of: eventKitManager.eventStore.calendars(for: .reminder))
            }
        }
        .navigationTitle("Calendars")
        .navigationBarTitleDisplayMode(.inline)
    }
}
