//
//  CalendarSelection.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/12/22.
//

import Dependencies
import EventKit
import SwiftUI

struct CalendarSelectionButton: View {
    
    @EnvironmentObject private var appSettings: AppSettings
    @State private var showingCalendarSelection: Bool = false
    
    var body: some View {
        Button(action: {
            self.showingCalendarSelection.toggle()
        }) {
            Spacer()
            Text("Select Calendars")
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 34)
                        .fill(Color(uiColor: .systemGray6)))
        .padding(.horizontal, 20)
        .sheet(isPresented: self.$showingCalendarSelection) {
            CalendarSelection(showingCalendarSelection: self.$showingCalendarSelection)
        }
    }
}

struct CalendarSelection: View {
    
    @Binding var showingCalendarSelection: Bool
    var selectedIds: [String] { appSettings.userSelectedCalendars.loadCalendarIds() }
    @EnvironmentObject var appSettings: AppSettings
    @Dependency(\.eventKitManager) private var eventKitManager
    
    func selectionList(of calendars: [EKCalendar], from selectedIds: [String]) -> some View {
        ForEach(calendars, id: \.self) { calendar in
            Button(action: {
                var newIds = self.appSettings.userSelectedCalendars.loadCalendarIds()
                if newIds.contains(where: { $0 == calendar.calendarIdentifier }) {
                    newIds.removeAll(where: { $0 == calendar.calendarIdentifier })
                    self.appSettings.userSelectedCalendars = newIds.archiveCalendars()
                } else {
                    newIds.append(calendar.calendarIdentifier)
                    self.appSettings.userSelectedCalendars = newIds.archiveCalendars()
                }
            }) {
                HStack {
                    Circle().fill(Color(cgColor: calendar.cgColor)).frame(width: 20, height: 20)
                    Text(calendar.title)
                        .foregroundColor(.blue1)
                    Spacer()
                    if selectedIds.contains(calendar.calendarIdentifier) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue1)
                    }
                }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section("Events") {
                        self.selectionList(of: eventKitManager.eventStore.calendars(for: .event), from: self.selectedIds)
                    }
                    Section("Reminders") {
                        self.selectionList(of: eventKitManager.eventStore.calendars(for: .reminder), from: self.selectedIds)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 22)
            .navigationTitle("Select Calendars")
            .toolbar(content:  {
                HStack {
                    Spacer()
                    Button("Done", action: { self.showingCalendarSelection.toggle() })
                }
            })
        }
    }
}
