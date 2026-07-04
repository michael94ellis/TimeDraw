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
                .listRowBackground(Color.clear)
                .environment(\.openCalendarItem, modifyItemViewModel.open)
            Section(header: Text("Events")) {
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
                    .listRowBackground(EmptyView())
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
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
            }
            Section(header: Text("Reminders")) {
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
                    .listRowBackground(EmptyView())
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
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
            }
            Rectangle()
                .fill(.clear)
                .frame(height: 150)
                .listRowSeparator(.hidden)
                .listRowBackground(EmptyView())
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(uiColor: .systemGroupedBackground))
        .refreshable(action: {
            self.itemList.updateData()
        })
        .onAppear {
            self.itemList.updateData()
        }
        .onChange(of: modifyItemViewModel.isAddEventTextFieldFocused) {
            if !modifyItemViewModel.isAddEventTextFieldFocused {
                self.itemList.updateData()
            }
        }
    }
}
