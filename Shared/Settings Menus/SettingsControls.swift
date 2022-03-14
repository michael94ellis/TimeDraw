//
//  SettingsControls.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/13/22.
//

import SwiftUI

struct SettingsControls:View {
    
    @ObservedObject var appSettings: AppSettings = .shared
        
    var body: some View {
        VStack {
            Toggle("Enable Daily Goal Text Area", isOn: self.appSettings.$isDailyGoalEnabled)
                .padding(.horizontal)
            Toggle("Enable Time Draw Clock", isOn: self.appSettings.$isTimeDrawClockEnabled)
                .padding(.horizontal)
            Toggle("Show Recurrence", isOn: self.appSettings.$showRecurringItems)
                .padding(.horizontal)
            Toggle("Show Notes", isOn: self.appSettings.$showNotes)
                .padding(.horizontal)
            Toggle("Show Calendar Picker", isOn: self.appSettings.$showCalendarPickerButton)
                .padding(.horizontal)
            Toggle("Show List Icons", isOn: self.appSettings.$showListIcons)
                .padding(.horizontal)
                .onChange(of: self.appSettings.showListIcons, perform: { newValue in
                    EventListViewModel.shared.updateData()
                })
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
            EventListViewModel.shared.updateData()
        })
        Picker("", selection: self.appSettings.$showItemRecurrenceType) {
            ForEach(ItemRecurrenceType.allCases ,id: \.self) { item in
                Text(item.displayName)
            }
        }
        .pickerStyle(.segmented)
        .padding(.top, 6)
        .onChange(of: self.appSettings.showItemRecurrenceType, perform: { _ in
            EventListViewModel.shared.updateData()
        })
    }
}
