//
//  AddNotesInput.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/10/22.
//

import SwiftUI

struct AddNotesInput: View {
    
    @EnvironmentObject var viewModel: ModifyCalendarItemViewModel
    @FocusState var notesInputFocus: Bool
    private let barHeight: CGFloat = 96
    
    var header: some View {
        HStack {
            Text("Notes")
                .padding(.horizontal)
            Spacer()
            Button(action: { self.viewModel.removeNotesFromEvent() }) {
                Text("Remove").foregroundColor(.red1)
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
    
    var body: some View {
        if self.viewModel.isNotesInputOpen {
            VStack {
                self.header
                Divider().padding(.horizontal)
                HStack {
                    MultilineTextField("Tap To Add Notes", text: self.$viewModel.notesInput, focus: self.$notesInputFocus)
                        .frame(maxWidth: 600)
                        .background(RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(uiColor: .systemGray5))
                                        .shadow(radius: 4, x: 2, y: 4))
                        .padding(.horizontal)
                        .padding(.bottom)
                }
            }
            .frame(maxWidth: 600)
            .background(RoundedRectangle(cornerRadius: 13).fill(Color(uiColor: .systemGray6))
                            .shadow(radius: 4, x: 2, y: 4))
        } else {
            Button(action: self.viewModel.addNotesToEvent) {
                Text("Add Notes")
                    .frame(height: 48)
                    .foregroundColor(Color.blue1)
                    .frame(maxWidth: 600)
                    .background(RoundedRectangle(cornerRadius: 13).fill(Color(uiColor: .systemGray6))
                                    .shadow(radius: 4, x: 2, y: 4))
            }
            .contentShape(Rectangle())
            .buttonStyle(.plain)
        }
    }
}
