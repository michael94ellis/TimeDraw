//
//  SettingsControls.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/13/22.
//

import SwiftUI

struct SettingsControls:View {
    
    @EnvironmentObject var appSettings: AppSettings
        
    var body: some View {
        VStack(spacing: 8) {
            VStack {
                Toggle("Enable Daily Goal Text Area", isOn: self.appSettings.$isDailyGoalEnabled)
                    .padding(.horizontal)
                Toggle("Enable Time Draw Clock", isOn: self.appSettings.$isTimeDrawClockEnabled)
                    .padding(.horizontal)
                Toggle("Show Recurrence", isOn: self.appSettings.$showRecurringItems)
                    .padding(.horizontal)
                Toggle("Show Calendar Picker", isOn: self.appSettings.$showCalendarPickerButton)
                    .padding(.horizontal)
                Toggle("Show List Icons", isOn: self.appSettings.$showListIcons)
                    .padding(.horizontal)
                    .onChange(of: self.appSettings.showListIcons, perform: { newValue in
                        CalendarItemListViewModel.shared.updateData()
                    })
                Toggle("Show Notes", isOn: self.appSettings.$showNotes)
                    .padding(.horizontal)
            }
            VStack {
                HStack {
                    Text("Note Line Limit:")
                    Picker("", selection: self.appSettings.$noteLineLimit) {
                        ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 15, 20, 25, 30], id: \.self) { amount in
                            Text(String(amount))
                        }
                    }
                    .frame(width: 100, height: 55)
                    .clipped()
                }
                HStack {
                    Text("Time Selection Interval:")
                    Picker("", selection: self.appSettings.$timePickerGranularity) {
                        ForEach([1, 2, 3, 5, 10, 12, 15, 20, 30], id: \.self) { minuteValue in
                            Text(String(minuteValue))
                        }
                    }
                    .frame(width: 100, height: 55)
                    .clipped()
                }
            }
            // Calendar Selection Popup Screen
            CalendarSelectionButton()
            // Show and Hide Segmented Pickers
            Text("Show:")
            Picker("", selection: self.appSettings.$showCalendarItemType) {
                ForEach(CalendarItemType.allCases ,id: \.self) { item in
                    Text(item.displayName)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: self.appSettings.showCalendarItemType, perform: { _ in
                CalendarItemListViewModel.shared.updateData()
            })
            Picker("", selection: self.appSettings.$showItemRecurrenceType) {
                ForEach(ItemRecurrenceType.allCases ,id: \.self) { item in
                    Text(item.displayName)
                }
            }
            .pickerStyle(.segmented)
            .padding(.top, 6)
            .onChange(of: self.appSettings.showItemRecurrenceType, perform: { _ in
                CalendarItemListViewModel.shared.updateData()
            })
        }
    }
}
