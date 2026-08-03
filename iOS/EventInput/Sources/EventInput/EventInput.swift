//
//  EventInput.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/6/22.
//

import Dependencies
import AppCore
import AppStoreReviewRequest
import DesignToken
import EventKit
import EventManagement
import EventUIComponents
import SwiftUI
import UIComponents

public struct EventInput: View {

    @Namespace private var animation

    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var viewModel: ModifyCalendarItemViewModel
    @EnvironmentObject var listViewModel: CalendarListViewModel
    private let eventStore = EKEventStore()

    @Dependency(\.eventKitManager) private var eventKitManager
    @FocusState private var isFocused: Bool
    private let defaultCalendarColor: CGColor = .init(red: 55, green: 91, blue: 190, alpha: 1)
    
    public init() { }
    
    private var submitSymbol: SFSymbol {
        viewModel.editMode ? .checkmark : .plus
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

    private var selectableEventCalendars: [EKCalendar] {
        eventStore
            .selectedCalendars(ids: selectedCalendarIds, entityType: .event)
            .filter { $0.allowsContentModifications }
    }

    private var selectableReminderCalendars: [EKCalendar] {
        eventStore
            .selectedCalendars(ids: selectedCalendarIds, entityType: .reminder)
            .filter { $0.allowsContentModifications }
    }

    private var showEventSection: Bool {
        !(viewModel.calendarItem is EKReminder)
    }

    private var showReminderSection: Bool {
        !(viewModel.calendarItem is EKEvent)
    }

    private var panelShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: CornerRadius.eventInputPanelRadius, style: .continuous)
    }

    public var body: some View {
        panelContent
            .background(panelShape.fill(.ultraThinMaterial))
            .clipShape(panelShape)
            .overlay(panelShape.strokeBorder(Colors.textFieldBorder.opacity(0.5), lineWidth: 0.5))
            .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
            .matchedGeometryEffect(id: "eventInput", in: animation)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .contentShape(panelShape)
            .animation(.spring(response: 0.35, dampingFraction: 0.86), value: viewModel.isAddEventTextFieldFocused)
            .sheet(isPresented: $viewModel.isShowingEventEditView, onDismiss: {
                viewModel.dismissEventEditView()
            }) {
                EventEditView(
                    eventStore: eventStore,
                    event: viewModel.eventBeingEdited
                ) { _ in
                    viewModel.dismissEventEditView()
                    viewModel.isShowingEventEditView = false
                }
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
        HStack(spacing: 12) {
            Text(viewModel.newItemTitle.isEmpty ? "New Event or Reminder" : viewModel.newItemTitle)
                .font(.app(.body))
                .foregroundStyle(viewModel.newItemTitle.isEmpty
                                 ? Colors.tertiaryText
                                 : Colors.primaryText)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            submitIcon
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .contentShape(panelShape)
        .onTapGesture {
            viewModel.isAddEventTextFieldFocused = true
        }
    }

    private var expandedContent: some View {
        VStack(spacing: 0) {
            FormSection(useGroupedBackground: true) {
                VStack(spacing: 0) {
                    titleFieldRow
                    
                    toolbarRow
                        .padding(.horizontal, 12)
                        .padding(.top, 4)
                        .padding(.bottom, 8)
                    
                    detailSections
                }
            }
        }
    }

    private var titleFieldRow: some View {
        HStack(spacing: 12) {
            TextField("New Event or Reminder", text: $viewModel.newItemTitle)
                .font(.app(.body))
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
                    ReviewRequestManager().requestReviewIfAppropriate(for: UserDefaults.standard)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .id("title")
    }

    private func submitButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            submitIcon
        }
        .buttonStyle(.plain)
    }

    private var submitIcon: some View {
        Image(submitSymbol)
            .font(.app(.icon))
            .foregroundStyle(Colors.onAccentBackground)
            .frame(width: 32, height: 32)
            .background(Circle().fill(Colors.action))
    }

    private var toolbarRow: some View {
        HStack(spacing: 12) {
            if viewModel.editMode {
                Button {
                    viewModel.reset()
                } label: {
                    Label("Cancel", systemImage: SFSymbol.xmark.rawValue)
                        .font(.app(.body))
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
            }
            
            calendarMenu
            
            Spacer()
            
            if viewModel.editMode {
                Button(role: .destructive,
                       action: {
                    Task {
                        await viewModel.delete()
                    }
                },
                       label: {
                    Image(.trashFill)
                        .frame(minWidth: 44, minHeight: 44)
                        .background {
                            RoundedRectangle(cornerRadius: CornerRadius.eventInputDeleteButton)
                                .strokeBorder(style: .init(lineWidth: 1.0))
                        }
                })
            }
        }
        .id("tools")
    }

    private var calendarMenu: some View {
        Menu {
            if showEventSection,
               eventKitManager.isEventAccessGranted(eventKitManager.eventAuthorizationStatus()),
               !selectableEventCalendars.isEmpty {
                Section("Events") {
                    calendarButtons(for: selectableEventCalendars)
                }
            }
            if showReminderSection,
               eventKitManager.isReminderAccessGranted(eventKitManager.reminderAuthorizationStatus()),
               !selectableReminderCalendars.isEmpty {
                Section("Reminders") {
                    calendarButtons(for: selectableReminderCalendars)
                }
            }
        } label: {
            HStack(spacing: 8) {
                Circle()
                    .fill(calendarTint)
                    .frame(width: 10, height: 10)
                Text(calendarName)
                    .font(.app(.body))
                    .foregroundStyle(Colors.primaryText)
                    .lineLimit(1)
                Image(.chevronUpChevronDown)
                    .font(.app(.listCaption))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
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
                        Image(.checkmark)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var detailSections: some View {
        AddEventDateTimePicker(displayDate: listViewModel.displayDate)
            .id("AddDateTime")
        if appSettings.showRecurringItems || viewModel.calendarItem?.hasRecurrenceRules ?? false {
            FormDivider(config: .subtle)
                .id("Divider1")
            AddRecurrenceRule()
                .id("Recurrence")
        }
        if viewModel.showsPriorityInput {
            FormDivider(config: .subtle)
                .id("DividerPriority")
            AddPriorityInput()
                .id("Priority")
        }
        FormDivider(config: .subtle)
            .id("Divider2")
        AddNotesInput()
            .id("Notes")
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
