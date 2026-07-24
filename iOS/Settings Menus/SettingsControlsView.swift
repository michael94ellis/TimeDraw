//
//  SettingsControlsView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/13/22.
//

import AppCore
import SwiftUI

struct SettingsControlsView: View {

    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var calendarItemListViewModel: CalendarItemListViewModel

    var body: some View {
        Section("Customize") {
            Toggle("Daily Goal Note Space", isOn: appSettings.$isDailyGoalEnabled)

            Picker("Time Selection Interval", selection: appSettings.$timePickerGranularity) {
                ForEach([1, 2, 3, 5, 10, 12, 15, 20, 30], id: \.self) { minuteValue in
                    Text("\(minuteValue) min").tag(minuteValue)
                }
            }

            NavigationLink {
                CalendarSelection()
            } label: {
                Text("Calendars")
            }
        }

        Section("Show") {
            Picker("Items", selection: appSettings.$showCalendarItemType) {
                ForEach(CalendarItemType.allCases, id: \.self) { item in
                    Text(item.displayName).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
            .onChange(of: appSettings.showCalendarItemType) {
                calendarItemListViewModel.updateData()
            }
            .listRowBackground(EmptyView())
            .listRowSeparator(.hidden)

            Picker("Recurrence", selection: appSettings.$showItemRecurrenceType) {
                ForEach(ItemRecurrenceType.allCases, id: \.self) { item in
                    Text(item.displayName).tag(item)
                }
            }
            .pickerStyle(.segmented)
            .listRowInsets(.init(top: 8, leading: 0, bottom: 8, trailing: 0))
            .onChange(of: appSettings.showItemRecurrenceType) {
                calendarItemListViewModel.updateData()
            }
            .listRowBackground(EmptyView())
            .listRowSeparator(.hidden)
        }
    }
}
