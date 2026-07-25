//
//  AddEventDateTimePicker.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/18/22.
//

import Dependencies
import AppCore
import DesignToken
import EventKit
import EventManagement
import EventUIComponents
import SwiftUI
import UIComponents

public struct AddEventDateTimePicker: View {

    @EnvironmentObject var viewModel: ModifyCalendarItemViewModel
    @Dependency(\.eventKitManager) private var eventKitManager
    let displayDate: Date

    private var isExpanded: Bool {
        viewModel.isDetailSectionExpanded(.dateTime)
    }
    
    init(displayDate: Date) {
        self.displayDate = displayDate
    }

    func setSuggestedTime() {
        Task {
            await viewModel.updateSelectedCalendar()
        }
    }

    private func addStartTime() {
        viewModel.newItemStartTime = Date.now.get(.hour, .minute, .second)
        viewModel.newItemStartDate = displayDate.get(.year, .month, .day)
    }

    private func clearStartTime() {
        viewModel.newItemStartDate = nil
        viewModel.newItemStartTime = nil
    }

    private var hasStartTime: Bool {
        viewModel.newItemStartDate != nil || viewModel.newItemStartTime != nil
    }
    private func addEndTime() {
        viewModel.newItemEndTime = Calendar.current.date(byAdding: .hour,
                                                         value: 1,
                                                         to: Date.now)?.get(
                                                            .hour,
                                                            .minute,
                                                            .second)
        viewModel.newItemEndDate = displayDate.get(.year, .month, .day)
    }

    private func clearEndime() {
        viewModel.newItemEndDate = nil
        viewModel.newItemEndTime = nil
    }

    private var hasEndTime: Bool {
        viewModel.newItemEndDate != nil || viewModel.newItemEndTime != nil
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
                    value: viewModel.dateTimeSummary,
                    isExpanded: isExpanded
                )
            }
            .buttonStyle(.plain)

            if isExpanded {
                FormDivider()
                VStack(spacing: 4) {
                    if hasStartTime {
                        HStack(spacing: 8) {
                            Button(role: .destructive, action: clearStartTime) {
                                Image(.xmark)
                                    .frame(minWidth: 44, minHeight: 44)
                                    .background {
                                        RoundedRectangle(cornerRadius: CornerRadius.eventInputDeleteButton)
                                            .strokeBorder(style: .init(lineWidth: 1.0))
                                    }
                            }
                            DatePicker("Starts",
                                       selection: startBinding,
                                       displayedComponents: [.date, .hourAndMinute])
                                .font(.app(.body))
                        }
                        .padding(.horizontal, 16)
                    } else {
                        Button("Add Start Time", action: addStartTime)
                            .font(.app(.body))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }
                    if hasEndTime {
                        HStack(spacing: 8) {
                            Button(role: .destructive, action: clearEndime) {
                                Image(.xmark)
                                    .frame(minWidth: 44, minHeight: 44)
                                    .background {
                                        RoundedRectangle(cornerRadius: CornerRadius.eventInputDeleteButton)
                                            .strokeBorder(style: .init(lineWidth: 1.0))
                                    }
                            }
                            DatePicker("Ends",
                                       selection: endBinding,
                                       displayedComponents: [.date, .hourAndMinute])
                                .font(.app(.body))
                        }
                        .padding(.horizontal, 16)
                    } else {
                        Button("Add End Time", action: addEndTime)
                            .font(.app(.body))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
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
