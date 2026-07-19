//
//  AddRecurrenceRule.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/20/22.
//

import SwiftUI
import EventKit

struct AddRecurrenceRule: View {

    @EnvironmentObject var viewModel: ModifyCalendarItemViewModel

    private var isExpanded: Bool {
        viewModel.isDetailSectionExpanded(.recurrence)
    }

    var body: some View {
        VStack(spacing: 0) {
            Button {
                viewModel.toggleDetailSection(.recurrence)
            } label: {
                SummaryRowLabel(
                    title: "Repeat",
                    value: viewModel.isRecurrencePickerOpen ? viewModel.recurrenceSummary : nil,
                    isExpanded: isExpanded
                )
            }
            .buttonStyle(.plain)

            if isExpanded {
                FormDivider()
                recurrenceDetails
            }
        }
    }

    private var recurrenceDetails: some View {
        VStack(spacing: 12) {
            Picker("Frequency", selection: $viewModel.selectedRule) {
                ForEach(EKRecurrenceFrequency.allCases, id: \.self) { rule in
                    Text(rule.description).tag(rule)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 12)
            .padding(.top, 8)

            recurrenceFrequencyContent
                .padding(.horizontal, 12)

            endConditionSection
                .padding(.horizontal, 12)
                .padding(.bottom, 12)

            HStack {
                Spacer()
                DestructiveTextButton(title: "Remove Repeat") {
                    viewModel.removeRecurrenceFromEvent()
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
    }

    @ViewBuilder
    private var recurrenceFrequencyContent: some View {
        switch viewModel.selectedRule {
        case .daily:
            Stepper(value: Binding(
                get: { viewModel.frequencyDayValueInt ?? 1 },
                set: { viewModel.frequencyDayValueInt = $0; viewModel.endRecurrenceDate = nil }
            ), in: 1...365) {
                Text("Every \(viewModel.frequencyDayValueInt ?? 1) day(s)")
                    .font(.interRegular)
            }
        case .weekly:
            MultiPicker(EKWeekday.allCases, selections: $viewModel.frequencyWeekdayValues)
                .padding(.vertical, 4)
        case .monthly:
            CalendarMultiDateSelection(selectedDates: $viewModel.selectedMonthDays)
        case .yearly:
            VStack(spacing: 8) {
                HStack {
                    Text("Month")
                        .font(.interRegular)
                    Spacer()
                    PickerField("Month", data: Calendar.current.monthSymbols, selectionIndex: $viewModel.frequencyMonthDate)
                        .frame(width: 140, height: 34)
                }
                CalendarMultiDateSelection(selectedDates: $viewModel.selectedMonthDays)
            }
        @unknown default:
            EmptyView()
        }
    }

    private var endConditionSection: some View {
        VStack(spacing: 8) {
            Picker("Ends", selection: $viewModel.isRecurrenceUsingOccurences) {
                Text("On date").tag(false)
                Text("After").tag(true)
            }
            .pickerStyle(.segmented)

            if viewModel.isRecurrenceUsingOccurences {
                Stepper(value: Binding(
                    get: { viewModel.numberOfOccurences ?? 1 },
                    set: { viewModel.numberOfOccurences = $0; viewModel.endRecurrenceDate = nil }
                ), in: 1...999) {
                    Text("\(viewModel.numberOfOccurences ?? 1) occurrence(s)")
                        .font(.interRegular)
                }
            } else {
                DateAndTimePickers(
                    dateTime: $viewModel.endRecurrenceTime,
                    dateDate: $viewModel.endRecurrenceDate,
                    onTap: { viewModel.setSuggestedEndRecurrenceDate() }
                )
            }
        }
    }
}
