//
//  SettingsControlsView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/13/22.
//

import AppCore
import DesignToken
import EventManagement
import SwiftUI

struct SettingsControlsView: View {

    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var calendarItemListViewModel: CalendarListViewModel
    @Environment(\.layoutMetrics) private var layoutMetrics

    var body: some View {
        Section {
            Toggle("Daily Goal Note Space", isOn: appSettings.$isDailyGoalEnabled)
                .font(.app(.body))

            Picker(selection: appSettings.$timePickerGranularity,
                   content: {
                ForEach([1, 2, 3, 5, 10, 12, 15, 20, 30], id: \.self) { minuteValue in
                    Text("\(minuteValue) min")
                        .font(.app(.listTitle))
                        .tag(minuteValue)
                }
            },
                   label: {
                Text("Time Selection Interval")
                    .font(.app(.body))
            })
            .font(.app(.body))

            NavigationLink {
                CalendarSelection()
            } label: {
                Text("Calendars")
                    .font(.app(.body))
            }
        } header: {
            Text("Customize")
                .font(.app(.listTitle))
        }

        Section {
            Picker("Items", selection: appSettings.$showCalendarItemType) {
                ForEach(CalendarItemType.allCases, id: \.self) { item in
                    Text(item.displayName)
                        .tag(item)
                }
            }
            .pickerStyle(.segmented)
            .font(.app(.body))
            .listRowInsets(.init(
                top: layoutMetrics.settingsSegmentedRowVerticalPadding,
                leading: 0,
                bottom: layoutMetrics.settingsSegmentedRowVerticalPadding,
                trailing: 0
            ))
            .onChange(of: appSettings.showCalendarItemType) {
                calendarItemListViewModel.updateData()
            }
            .listRowBackground(EmptyView())
            .listRowSeparator(.hidden)

            Picker("Recurrence", selection: appSettings.$showItemRecurrenceType) {
                ForEach(ItemRecurrenceType.allCases, id: \.self) { item in
                    Text(item.displayName)
                        .tag(item)
                }
            }
            .pickerStyle(.segmented)
            .listRowInsets(.init(
                top: layoutMetrics.settingsSegmentedRowVerticalPadding,
                leading: 0,
                bottom: layoutMetrics.settingsSegmentedRowVerticalPadding,
                trailing: 0
            ))
            .onChange(of: appSettings.showItemRecurrenceType) {
                calendarItemListViewModel.updateData()
            }
            .listRowBackground(EmptyView())
            .listRowSeparator(.hidden)
        } header: {
            Text("Show")
                .font(.app(.listTitle))
        }
    }
}
