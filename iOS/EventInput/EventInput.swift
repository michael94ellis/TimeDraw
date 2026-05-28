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
        viewModel.editMode ? "checkmark.circle.fill" : "plus.circle.fill"
    }

    private var calendarName: String {
        viewModel.selectedCalendar?.title ?? "Calendar"
    }

    var body: some View {
        Group {
            if viewModel.isAddEventTextFieldFocused {
                expandedPanel
            } else {
                collapsedBar
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.isAddEventTextFieldFocused)
    }

    private var collapsedBar: some View {
        Button {
            viewModel.isAddEventTextFieldFocused = true
        } label: {
            HStack(spacing: 12) {
                Text(viewModel.newItemTitle.isEmpty ? "New Event or Reminder" : viewModel.newItemTitle)
                    .font(.interRegular)
                    .foregroundStyle(viewModel.newItemTitle.isEmpty ? .secondary : Color(uiColor: .label))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: submitIconName)
                    .font(.title2)
                    .foregroundStyle(Color.blue1)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            .overlay(alignment: .top) {
                Divider()
            }
        }
        .buttonStyle(.plain)
        .matchedGeometryEffect(id: "textInput", in: animation)
        .padding(.horizontal, 14)
        .padding(.bottom, 8)
    }

    private var expandedPanel: some View {
        ScrollView {
            VStack(spacing: 12) {
                titleFieldRow
                toolbarRow
                detailSections
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 8)
        }
        .scrollDismissesKeyboard(.interactively)
        .frame(maxHeight: 420)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Divider()
        }
    }

    private var titleFieldRow: some View {
        HStack(spacing: 12) {
            TextField("New Event or Reminder", text: $viewModel.newItemTitle)
                .font(.interRegular)
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit { isFocused = false }
                .onChange(of: viewModel.isAddEventTextFieldFocused) { isFocused = $0 }
                .onAppear { isFocused = true }

            Button {
                Task {
                    await viewModel.submitEventOrReminder()
                    isFocused = false
                }
            } label: {
                Image(systemName: submitIconName)
                    .font(.title2)
                    .foregroundStyle(Color.blue1)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .insetGroupedBackground()
        .matchedGeometryEffect(id: "textInput", in: animation)
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
        .padding(.horizontal, 4)
    }

    private var calendarMenu: some View {
        Menu {
            ForEach(appSettings.userSelectedCalendars.loadCalendarIds(), id: \.self) { calendarId in
                if let calendar = eventKitManager.eventStore.calendar(withIdentifier: calendarId) {
                    Button {
                        viewModel.selectedCalendar = calendar
                    } label: {
                        Label(calendar.title, systemImage: viewModel.selectedCalendar?.calendarIdentifier == calendarId ? "checkmark" : "")
                    }
                }
            }
        } label: {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(cgColor: viewModel.selectedCalendar?.cgColor ?? defaultCalendarColor))
                    .frame(width: 10, height: 10)
                Text(calendarName)
                    .font(.interRegular)
                    .foregroundStyle(Color(uiColor: .label))
                    .lineLimit(1)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(uiColor: .tertiarySystemGroupedBackground), in: Capsule())
        }
    }

    @ViewBuilder
    private var detailSections: some View {
        FormSection {
            AddEventDateTimePicker()
            if appSettings.showRecurringItems || viewModel.calendarItem?.hasRecurrenceRules ?? false {
                FormDivider()
                AddRecurrenceRule()
            }
            FormDivider()
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
