//
//  EventsAndRemindersMainList.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/20/22.
//

import SwiftUI
import EventKit

struct MainScrollableContent: View {
    
    @EnvironmentObject private var modifyItemViewModel: ModifyCalendarItemViewModel
    @EnvironmentObject private var itemList: CalendarItemListViewModel
    @EnvironmentObject private var appSettings: AppSettings
    let clockHorizPadding: CGFloat = 16
    let clockVertPadding: CGFloat = 20
    
    func performComplete(for item: EKReminder) {
        self.itemList.completeReminder(item)
        self.modifyItemViewModel.saveAndDisplayToast(reminder: item, "Reminder Completed")
    }
        
    var body: some View {
        List {
            TimeDrawClock(events: itemList.events, reminders: itemList.reminders)
                .padding(.vertical, clockVertPadding)
                .padding(.horizontal, clockHorizPadding)
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .environment(\.openCalendarItem, modifyItemViewModel.open)
            ForEach(self.itemList.events) { item in
                Button(action: {
                    withAnimation {
                        self.modifyItemViewModel.open(event: item)
                    }
                }) {
                    EventListCell(item: item)
                }
                .buttonStyle(.plain)
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 2, leading: 16, bottom: 2, trailing: 16))
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
                .swipeActions(allowsFullSwipe: true) {
                    Button(action: {
                        self.itemList.delete(item)
                        self.modifyItemViewModel.displayToast("Event Deleted", style: .destructive)
                        self.itemList.updateData()
                    }) {
                        Image(systemName: "trash")
                            .tint(Color.red1)
                    }
                }
            }
            ForEach(self.itemList.reminders) { item in
                Button(action: {
                    withAnimation {
                        self.modifyItemViewModel.open(reminder: item)
                    }
                }) {
                    ReminderListCell(item: item)
                }
                .buttonStyle(.plain)
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 2, leading: 16, bottom: 2, trailing: 16))
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                )
                .swipeActions(allowsFullSwipe: true) {
                    Button(action: {
                        self.performComplete(for: item)
                        self.itemList.updateData()
                    }) {
                        Image(systemName: "checkmark")
                            .tint(Color.green1)
                    }
                    Button(action: {
                        self.itemList.delete(item)
                        self.modifyItemViewModel.displayToast("Reminder Deleted", style: .destructive)
                        self.itemList.updateData()
                    }) {
                        Image(systemName: "trash")
                            .tint(Color.red1)
                    }
                }
            }
            Spacer(minLength: 120)
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .environment(\.defaultMinListRowHeight, 0)
        .listRowSpacing(4)
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(uiColor: .systemGroupedBackground))
        .refreshable(action: {
            self.itemList.updateData()
        })
        .onChange(of: modifyItemViewModel.isAddEventTextFieldFocused) { newValue in
            if !newValue {
                self.itemList.updateData()
            }
        }
    }
}
