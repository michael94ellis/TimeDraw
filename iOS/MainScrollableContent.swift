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
    let clockHorizPadding: CGFloat = 100
    let clockVertPadding: CGFloat = 20
    
    func performComplete(for item: EKReminder) {
        self.itemList.completeReminder(item)
        self.modifyItemViewModel.saveAndDisplayToast(reminder: item, "Completed")
        self.modifyItemViewModel.displayToast("Reminder Completed")
    }
        
    var body: some View {
        List {
            TimeDrawClock()
                .padding(.vertical, clockVertPadding)
                .padding(.horizontal, clockHorizPadding)
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
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
                .listRowInsets(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
                .swipeActions(allowsFullSwipe: true) {
                    Button(action: {
                        self.itemList.delete(item)
                        self.modifyItemViewModel.displayToast("Event Deleted")
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
                .listRowInsets(.init(top: 4, leading: 8, bottom: 4, trailing: 8))
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
                        self.modifyItemViewModel.displayToast("Reminder Deleted")
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
        .listRowSpacing(0)
        .listStyle(.plain)
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
