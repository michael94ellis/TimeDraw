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
                Toggle("Daily Goal Note Space", isOn: self.appSettings.$isDailyGoalEnabled)
                Toggle("Analog Clock", isOn: self.appSettings.$isTimeDrawClockEnabled)
                HStack {
                    Text("Time Selection Interval")
                    Spacer()
                    Picker("", selection: self.appSettings.$timePickerGranularity) {
                        ForEach([1, 2, 3, 5, 10, 12, 15, 20, 30], id: \.self) { minuteValue in
                            Text("  \(String(minuteValue))m")
                        }
                    }
                    .frame(width: 55, height: 55)
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
