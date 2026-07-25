//
//  AddPriorityInput.swift
//  TimeDraw
//

import EventKit
import EventManagement
import SwiftUI
import UIComponents

struct AddPriorityInput: View {

    @EnvironmentObject var viewModel: ModifyCalendarItemViewModel

    private var isExpanded: Bool {
        viewModel.isDetailSectionExpanded(.priority)
    }

    var body: some View {
        VStack(spacing: 0) {
            Button {
                viewModel.toggleDetailSection(.priority)
            } label: {
                SummaryRowLabel(
                    title: "Priority",
                    value: viewModel.prioritySummary,
                    isExpanded: isExpanded
                )
            }
            .buttonStyle(.plain)

            if isExpanded {
                FormDivider()
                Picker("Priority", selection: $viewModel.selectedPriority) {
                    ForEach(EKReminderPriority.selectableCases, id: \.self) { priority in
                        Text(priority.displayName).tag(priority)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
            }
        }
    }
}
