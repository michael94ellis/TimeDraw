//
//  SettingsControls.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/13/22.
//

import SwiftUI

struct SettingsControls:View {
    
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var calendarItemListViewModel: CalendarItemListViewModel
    
    func sectionLabel(title sectionName: String) -> some View {
        HStack {
            Text(sectionName)
                .font(.title2)
            Spacer()
        }
    }
        
    var body: some View {
        VStack(spacing: 8) {
            sectionLabel(title: "Customize")
            VStack {
                Toggle("Daily Goal Note Space", isOn: self.appSettings.$isDailyGoalEnabled)
                HStack {
                    Text("Time Selection Interval")
                    Spacer()
                    Picker("", selection: self.appSettings.$timePickerGranularity) {
                        ForEach([1, 2, 3, 5, 10, 12, 15, 20, 30], id: \.self) { minuteValue in
                            Text("  \(String(minuteValue))m")
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            // Calendar Selection Popup Screen
            CalendarSelectionButton()
            sectionLabel(title: "Show")
            Picker("", selection: self.appSettings.$showCalendarItemType) {
                ForEach(CalendarItemType.allCases ,id: \.self) { item in
                    Text(item.displayName)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: self.appSettings.showCalendarItemType, perform: { _ in
                calendarItemListViewModel.updateData()
            })
            Picker("", selection: self.appSettings.$showItemRecurrenceType) {
                ForEach(ItemRecurrenceType.allCases ,id: \.self) { item in
                    Text(item.displayName)
                }
            }
            .pickerStyle(.segmented)
            .padding(.top, 6)
            .onChange(of: self.appSettings.showItemRecurrenceType, perform: { _ in
                calendarItemListViewModel.updateData()
            })
        }
    }
}
