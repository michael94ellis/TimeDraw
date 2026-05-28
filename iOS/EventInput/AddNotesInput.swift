//
//  AddNotesInput.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/10/22.
//

import SwiftUI

struct AddNotesInput: View {

    @EnvironmentObject var viewModel: ModifyCalendarItemViewModel
    @FocusState private var notesInputFocus: Bool

    var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation {
                    if viewModel.isNotesInputOpen {
                        notesInputFocus = true
                    } else {
                        viewModel.addNotesToEvent()
                        notesInputFocus = true
                    }
                }
            } label: {
                SummaryRowLabel(
                    title: "Notes",
                    value: viewModel.isNotesInputOpen ? (viewModel.notesSummary ?? "Add") : nil,
                    isExpanded: viewModel.isNotesInputOpen
                )
            }
            .buttonStyle(.plain)

            if viewModel.isNotesInputOpen {
                FormDivider()
                VStack(alignment: .leading, spacing: 8) {
                    TextEditor(text: $viewModel.notesInput)
                        .font(.interRegular)
                        .frame(minHeight: 80, maxHeight: 120)
                        .focused($notesInputFocus)
                        .scrollContentBackground(.hidden)

                    HStack {
                        Spacer()
                        DestructiveTextButton(title: "Remove Notes") {
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
