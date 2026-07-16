//
//  EventInput.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/6/22.
//

import Dependencies
import EventKit
import SwiftUI

struct EventInput: View {

    @Namespace private var animation

    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var viewModel: ModifyCalendarItemViewModel

    @Dependency(\.eventKitManager) private var eventKitManager
    @FocusState private var isFocused: Bool

    private var defaultCalendarColor: CGColor {
        eventKitManager.defaultReminderCalendar?.cgColor ?? .init(red: 55, green: 91, blue: 190, alpha: 1)
    }

    private var submitIconName: String {
        viewModel.editMode ? "checkmark" : "plus"
    }

    private var calendarName: String {
        viewModel.selectedCalendar?.title ?? "Calendar"
    }

    private var calendarTint: Color {
        Color(cgColor: viewModel.selectedCalendar?.cgColor ?? defaultCalendarColor)
    }

    private var selectedCalendarIds: [String] {
        appSettings.userSelectedCalendars.loadCalendarIds()
    }

    private var selectedEventCalendars: [EKCalendar] {
        eventKitManager.eventStore.selectedCalendars(ids: selectedCalendarIds, entityType: .event)
    }

    private var selectedReminderCalendars: [EKCalendar] {
        eventKitManager.eventStore.selectedCalendars(ids: selectedCalendarIds, entityType: .reminder)
    }

    private var showEventSection: Bool {
        !(viewModel.calendarItem is EKReminder)
    }

    private var showReminderSection: Bool {
        !(viewModel.calendarItem is EKEvent)
    }

    var body: some View {
        panelContainer
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .animation(.spring(response: 0.35, dampingFraction: 0.86), value: viewModel.isAddEventTextFieldFocused)
            .sheet(isPresented: $viewModel.isShowingEventEditView, onDismiss: {
                viewModel.dismissEventEditView()
            }) {
                EventEditView(
                    eventStore: eventKitManager.eventStore,
                    event: viewModel.eventBeingEdited
                ) { _ in
                    viewModel.dismissEventEditView()
                    viewModel.isShowingEventEditView = false
                }
            }
    }

    @ViewBuilder
    private var panelContainer: some View {
        let content = panelContent
            .glassPanel()

        if #available(iOS 26, *) {
            GlassEffectContainer {
                content
                    .glassEffectID("eventInput", in: animation)
            }
        } else {
            content
                .matchedGeometryEffect(id: "eventInput", in: animation)
        }
    }

    @ViewBuilder
    private var panelContent: some View {
        if viewModel.isAddEventTextFieldFocused {
            expandedContent
        } else {
            collapsedContent
        }
    }

    private var collapsedContent: some View {
        Button {
            viewModel.isAddEventTextFieldFocused = true
        } label: {
            HStack(spacing: 12) {
                Text(viewModel.newItemTitle.isEmpty ? "New Event or Reminder" : viewModel.newItemTitle)
                    .font(.interRegular)
                    .foregroundStyle(viewModel.newItemTitle.isEmpty ? DesignToken.Colors.tertiaryText : DesignToken.Colors.primaryText)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                submitIcon
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    private var expandedContent: some View {
        VStack(spacing: 0) {
            titleFieldRow

            toolbarRow
                .padding(.horizontal, 12)
                .padding(.top, 4)
                .padding(.bottom, 8)

            ScrollView {
                detailSections
            }
            .scrollDismissesKeyboard(.interactively)
            .frame(maxHeight: 320)
        }
    }

    private var titleFieldRow: some View {
        HStack(spacing: 12) {
            TextField("New Event or Reminder", text: $viewModel.newItemTitle)
                .font(.interRegular)
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit { isFocused = false }
                .onChange(of: viewModel.isAddEventTextFieldFocused) {
                    isFocused = viewModel.isAddEventTextFieldFocused
                }
                .onAppear { isFocused = true }

            submitButton {
                Task {
                    await viewModel.submitEventOrReminder()
                    isFocused = false
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func submitButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            submitIcon
        }
        .buttonStyle(.plain)
    }

    private var submitIcon: some View {
        Image(systemName: submitIconName)
            .font(.body.weight(.semibold))
            .foregroundStyle(.white)
            .frame(width: 32, height: 32)
            .glassSubmitButton(tint: DesignToken.Colors.action)
    }

    private var toolbarRow: some View {
        HStack(spacing: 12) {
            if viewModel.editMode {
                Button {
                    viewModel.reset()
                } label: {
                    Label("Cancel", systemImage: "xmark")
                        .font(.interRegular)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }

            calendarMenu

            Spacer()

            if viewModel.editMode {
                DestructiveTextButton(title: "Delete") {
                    viewModel.delete()
                }
            }
        }
    }

    private var calendarMenu: some View {
        Menu {
            if showEventSection,
               eventKitManager.isEventAccessGranted(eventKitManager.eventAuthorizationStatus()),
               !selectedEventCalendars.isEmpty {
                Section("Events") {
                    calendarButtons(for: selectedEventCalendars)
                }
            }
            if showReminderSection,
               eventKitManager.isReminderAccessGranted(eventKitManager.reminderAuthorizationStatus()),
               !selectedReminderCalendars.isEmpty {
                Section("Reminders") {
                    calendarButtons(for: selectedReminderCalendars)
                }
            }
        } label: {
            HStack(spacing: 8) {
                Circle()
                    .fill(calendarTint)
                    .frame(width: 10, height: 10)
                Text(calendarName)
                    .font(.interRegular)
                    .foregroundStyle(DesignToken.Colors.primaryText)
                    .lineLimit(1)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .glassCapsuleChip(tint: calendarTint)
        }
    }

    @ViewBuilder
    private func calendarButtons(for calendars: [EKCalendar]) -> some View {
        ForEach(calendars, id: \.calendarIdentifier) { calendar in
            Button {
                viewModel.selectCalendar(calendar)
            } label: {
                HStack {
                    Circle()
                        .fill(Color(cgColor: calendar.cgColor))
                        .frame(width: 10, height: 10)
                    Text(calendar.title)
                    Spacer()
                    if viewModel.selectedCalendar?.calendarIdentifier == calendar.calendarIdentifier {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var detailSections: some View {
        FormSection(useGroupedBackground: false) {
            AddEventDateTimePicker()
            if appSettings.showRecurringItems || viewModel.calendarItem?.hasRecurrenceRules ?? false {
                FormDivider(subtle: true)
                AddRecurrenceRule()
            }
            FormDivider(subtle: true)
            AddNotesInput()
        }
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}
