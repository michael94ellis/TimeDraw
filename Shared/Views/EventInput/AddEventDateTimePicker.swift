//
//  AddEventDateTimePicker.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/18/22.
//

import Dependencies
import DesignToken
import EventKit
import EventUIComponents
import SwiftUI
import UIComponents

public struct AddEventDateTimePicker: View {

    @EnvironmentObject var viewModel: ModifyCalendarItemViewModel
    @EnvironmentObject var calendarItemListViewModel: CalendarItemListViewModel
    @Dependency(\.eventKitManager) private var eventKitManager

    private var isExpanded: Bool {
        viewModel.isDetailSectionExpanded(.dateTime)
    }

    func setSuggestedTime() {
        let displayDate = calendarItemListViewModel.displayDate
        if viewModel.newItemStartTime == nil {
            viewModel.newItemStartTime = displayDate.get(.hour, .minute, .second)
        }
        if viewModel.newItemStartDate == nil {
            viewModel.newItemStartDate = displayDate.get(.year, .month, .day)
        }
        if viewModel.newItemEndTime == nil {
            viewModel.newItemEndTime = Calendar.current.date(byAdding: .hour, value: 1, to: displayDate)?.get(.hour, .minute, .second)
        }
        if viewModel.newItemEndDate == nil {
            viewModel.newItemEndDate = displayDate.get(.year, .month, .day)
        }
        if viewModel.selectedCalendar == nil {
            viewModel.selectedCalendar = eventKitManager.eventStore.defaultCalendarForNewEvents
        }
    }

    private var startBinding: Binding<Date> {
        dateBinding(date: $viewModel.newItemStartDate, time: $viewModel.newItemStartTime)
    }

    private var endBinding: Binding<Date> {
        dateBinding(date: $viewModel.newItemEndDate, time: $viewModel.newItemEndTime)
    }

    public var body: some View {
        VStack(spacing: 0) {
            Button {
                let wasExpanded = isExpanded
                viewModel.toggleDetailSection(.dateTime)
                if !wasExpanded {
                    setSuggestedTime()
                }
            } label: {
                SummaryRowLabel(
                    title: "Date & Time",
                    value: viewModel.isDateTimePickerOpen ? viewModel.dateTimeSummary : nil,
                    isExpanded: isExpanded
                )
            }
            .buttonStyle(.plain)

            if isExpanded {
                FormDivider()
                VStack(spacing: 4) {
                    DatePicker("Starts",
                               selection: startBinding,
                               displayedComponents: [.date, .hourAndMinute])
                        .font(.interRegular)
                        .padding(.horizontal, 12)
                    DatePicker("Ends",
                               selection: endBinding,
                               displayedComponents: [.date, .hourAndMinute])
                        .font(.interRegular)
                        .padding(.horizontal, 12)
                    
                    if let calendarItem = viewModel.calendarItem,
                       calendarItem is EKReminder
                        || !viewModel.editMode {
                        HStack {
                            Spacer()
                            DestructiveTextButton(title: "Remove Time") {
                                viewModel.removeTimeFromEvent()
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                    }
                }
                .padding(.top, 4)
                .onAppear(perform: setSuggestedTime)
            }
        }
    }

    private func dateBinding(date: Binding<DateComponents?>, time: Binding<DateComponents?>) -> Binding<Date> {
        Binding(
            get: {
                CalendarDisplayFormatters.mergedDate(date: date.wrappedValue, time: time.wrappedValue) ?? Date()
            },
            set: { newValue in
                date.wrappedValue = Calendar.current.dateComponents([.year, .month, .day], from: newValue)
                time.wrappedValue = Calendar.current.dateComponents([.hour, .minute, .second], from: newValue)
            }
        )
    }
}
