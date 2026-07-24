//
//  AddNotesInput.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/10/22.
//

import SwiftUI
import AppCore
import UIComponents

struct AddNotesInput: View {

    @EnvironmentObject var viewModel: ModifyCalendarItemViewModel
    @FocusState private var notesInputFocus: Bool

    private var isExpanded: Bool {
        viewModel.isDetailSectionExpanded(.notes)
    }

    private var notesRowValue: String? {
        if isExpanded {
            return viewModel.notesSummary ?? "Add"
        }
        return viewModel.notesSummary
    }

    var body: some View {
        VStack(spacing: 0) {
            Button {
                let wasExpanded = isExpanded
                viewModel.toggleDetailSection(.notes)
                if !wasExpanded {
                    notesInputFocus = true
                } else {
                    notesInputFocus = false
                }
            } label: {
                SummaryRowLabel(
                    title: "Notes",
                    value: notesRowValue,
                    isExpanded: isExpanded
                )
            }
            .buttonStyle(.plain)

            if isExpanded {
                FormDivider()
                VStack(alignment: .leading, spacing: 8) {
                    TextEditor(text: $viewModel.notesInput)
                        .font(.app(.body))
                        .frame(minHeight: 80, maxHeight: 120)
                        .focused($notesInputFocus)
                        .scrollContentBackground(.hidden)

                    HStack {
                        Spacer()
                        DestructiveTextButton(title: "Remove Notes") {
                            notesInputFocus = false
                            viewModel.removeNotesFromEvent()
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
    }
}
