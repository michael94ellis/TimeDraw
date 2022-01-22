//
//  AddEventDateTimePicker.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/18/22.
//

import SwiftUI

struct AddEventDateTimePicker: View {
    
    @EnvironmentObject var viewModel: AddEventViewModel
    @State var showDates: Bool = false
    private let barHeight: CGFloat = 96
    
    var body: some View {
        if self.viewModel.isTimePickerOpen {
            VStack {
                HStack {
                    Text("Time")
                        .padding(.horizontal)
                    Spacer()
                    Button(action: { self.viewModel.removeTimeFromEvent() }) {
                        Text("Remove").foregroundColor(.red1)
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
                Divider()
                    .padding(.horizontal)
                HStack {
                    DateTimePickerInputView(date: self.viewModel.newItemStartDateBinding, placeholder: "Start", mode: .time)
                        .frame(height: 30)
                        .padding(.vertical, 4)
                        .background(RoundedRectangle(cornerRadius: 4).fill(Color.lightGray1))
                        .onTapGesture {
                            if self.viewModel.newItemStartDate == nil {
                                self.viewModel.newItemStartDate = Date()
                            }
                        }
                    Text("to")
                    DateTimePickerInputView(date: self.viewModel.newItemEndDateBinding, placeholder: "End", mode: .time)
                        .frame(width: 150, height: 30)
                        .padding(.vertical, 4)
                        .background(RoundedRectangle(cornerRadius: 4).fill(Color.lightGray1))
                        .onTapGesture {
                            if self.viewModel.newItemEndDate == nil {
                                self.viewModel.newItemEndDate = Date().addingTimeInterval(60 * 60)
                            }
                        }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .frame(width: 362)
            .background(RoundedRectangle(cornerRadius: 13)
                            .fill(Color(uiColor: .systemGray6))
                            .shadow(radius: 4, x: 2, y: 4))
        } else {
            Button(action: self.viewModel.addTimeToEvent) {
                Text("Add Time")
                    .frame(maxWidth: 600)
                    .frame(height: 48)
                    .foregroundColor(Color.blue1)
                    .contentShape(Rectangle())
                    .background(RoundedRectangle(cornerRadius: 13).fill(Color.lightGray2).frame(width: 360, height: 60)
                                    .shadow(radius: 4, x: 2, y: 4))
            }
            .buttonStyle(.plain)
        }
    }
}
