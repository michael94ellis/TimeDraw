//
//  EventsAndRemindersMainList.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/20/22.
//

import Dependencies
import SwiftUI
import EventKit

struct MainScrollableContent: View {
    
    @EnvironmentObject private var modifyItemViewModel: ModifyCalendarItemViewModel
    @EnvironmentObject private var itemList: CalendarItemListViewModel
    @EnvironmentObject private var appSettings: AppSettings
    @Environment(\.scenePhase) private var scenePhase
    @Dependency(\.eventKitManager) private var eventKitManager

    @State private var eventAuthStatus: EKAuthorizationStatus = .notDetermined
    @State private var reminderAuthStatus: EKAuthorizationStatus = .notDetermined
    @State private var isEventsPermissionPlaceholderDismissed = false
    @State private var isRemindersPermissionPlaceholderDismissed = false

    let clockHorizPadding: CGFloat = 16
    let clockVertPadding: CGFloat = 20
    let standardRowInsets: EdgeInsets = .init(top: 4, leading: 8, bottom: 4, trailing: 8)

    private var showsEventsSection: Bool {
        switch appSettings.showCalendarItemType {
        case .scheduled, .all:
            return true
        case .unscheduled:
            return false
        }
    }

    private var showsRemindersSection: Bool {
        switch appSettings.showCalendarItemType {
        case .unscheduled, .all:
            return true
        case .scheduled:
            return false
        }
    }

    private var isEventAccessGranted: Bool {
        eventKitManager.isEventAccessGranted(eventAuthStatus)
    }

    private var isReminderAccessGranted: Bool {
        eventKitManager.isReminderAccessGranted(reminderAuthStatus)
    }

    func performComplete(for item: EKReminder) {
        self.itemList.completeReminder(item)
        self.modifyItemViewModel.saveAndDisplayToast(reminder: item, "Reminder Completed")
    }

    func refreshAuthStatuses() {
        eventAuthStatus = eventKitManager.eventAuthorizationStatus()
        reminderAuthStatus = eventKitManager.reminderAuthorizationStatus()
        if isEventAccessGranted {
            isEventsPermissionPlaceholderDismissed = false
        }
        if isReminderAccessGranted {
            isRemindersPermissionPlaceholderDismissed = false
        }
    }

    private func emptyEventsMessage() -> String {
        Calendar.current.isDateInToday(itemList.displayDate)
            ? "No Events Scheduled Today"
            : "No Events Scheduled"
    }

    private func emptyRemindersMessage() -> String {
        Calendar.current.isDateInToday(itemList.displayDate)
            ? "No Reminders Today"
            : "No Reminders"
    }

    @ViewBuilder
    private func emptyStateText(_ message: String) -> some View {
        Text(message)
            .font(.interRegular)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .listRowSeparator(.hidden)
            .listRowBackground(EmptyView())
    }

    @ViewBuilder
    private func eventsSectionContent() -> some View {
        if !isEventAccessGranted {
            if !isEventsPermissionPlaceholderDismissed {
                DismissableEventKitPermissionPlaceholder(
                    message: "Allow calendar access to see your events in TimeDraw.",
                    authorizationStatus: eventAuthStatus,
                    isAccessGranted: eventKitManager.isEventAccessGranted,
                    onDismiss: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isEventsPermissionPlaceholderDismissed = true
                        }
                    }
                )
            }
        } else if itemList.events.isEmpty {
            emptyStateText(emptyEventsMessage())
        } else {
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
                    .background(
                        RoundedRectangle(cornerRadius: DesignToken.CornerRadius.listRowRadius, style: .continuous)
                            .fill(DesignToken.Colors.listRowBackground)
                    )
                    .swipeActions(allowsFullSwipe: true) {
                        Button(action: {
                            self.itemList.delete(item)
                            self.modifyItemViewModel.displayToast("Event Deleted", style: .destructive)
                            self.itemList.updateData()
                        }) {
                            Image(systemName: "trash")
                                .tint(DesignToken.Colors.destructive)
                        }
                    }
                }
            }
            .listRowInsets(standardRowInsets)
            .listRowSpacing(0)
            .listRowSeparator(.hidden)
            .listRowBackground(EmptyView())
        }
    }

    @ViewBuilder
    private func remindersSectionContent() -> some View {
        if !isReminderAccessGranted {
            if !isRemindersPermissionPlaceholderDismissed {
                DismissableEventKitPermissionPlaceholder(
                    message: "Allow reminders access to see your reminders in TimeDraw.",
                    authorizationStatus: reminderAuthStatus,
                    isAccessGranted: eventKitManager.isReminderAccessGranted,
                    onDismiss: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isRemindersPermissionPlaceholderDismissed = true
                        }
                    }
                )
            }
        } else if itemList.reminders.isEmpty {
            emptyStateText(emptyRemindersMessage())
        } else {
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
                    .background(
                        RoundedRectangle(cornerRadius: DesignToken.CornerRadius.listRowRadius, style: .continuous)
                            .fill(DesignToken.Colors.listRowBackground)
                    )
                    .swipeActions(allowsFullSwipe: true) {
                        Button(action: {
                            self.performComplete(for: item)
                            self.itemList.updateData()
                        }) {
                            Image(systemName: "checkmark")
                                .tint(DesignToken.Colors.success)
                        }
                        Button(action: {
                            self.itemList.delete(item)
                            self.modifyItemViewModel.displayToast("Reminder Deleted", style: .destructive)
                            self.itemList.updateData()
                        }) {
                            Image(systemName: "trash")
                                .tint(DesignToken.Colors.destructive)
                        }
                    }
                }
            }
            .listRowInsets(standardRowInsets)
            .listRowSpacing(0)
            .listRowSeparator(.hidden)
            .listRowBackground(EmptyView())
        }
    }
        
    var body: some View {
        List {
            TimeDrawClock(events: itemList.events, reminders: itemList.reminders)
                .padding(.vertical, clockVertPadding)
                .padding(.horizontal, clockHorizPadding)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .environment(\.openCalendarItem, modifyItemViewModel.open)
            if showsEventsSection {
                eventsSectionContent()
            }
            if showsRemindersSection {
                remindersSectionContent()
            }
            Rectangle()
                .fill(.clear)
                .frame(height: 150)
                .listRowSeparator(.hidden)
                .listRowBackground(EmptyView())
        }
        .listSectionSpacing(0)
        .listRowSpacing(0)
        .environment(\.defaultMinListRowHeight, 0)
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(DesignToken.Colors.groupedBackground)
        .refreshable(action: {
            self.itemList.updateData()
        })
        .onAppear {
            refreshAuthStatuses()
            self.itemList.updateData()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                refreshAuthStatuses()
                self.itemList.updateData()
            }
        }
        .onChange(of: modifyItemViewModel.isAddEventTextFieldFocused) {
            if !modifyItemViewModel.isAddEventTextFieldFocused {
                self.itemList.updateData()
            }
        }
        .onChange(of: modifyItemViewModel.isShowingEventEditView) {
            if !modifyItemViewModel.isShowingEventEditView {
                self.itemList.updateData()
            }
        }
    }
}
