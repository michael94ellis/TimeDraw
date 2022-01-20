//
//  AddEventDatePicker.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/18/22.
//

import SwiftUI

struct AddEventDatePicker: View {
    
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @Binding var isDisplayed: Bool
    @Binding var isShowingDatePicker: Bool
    private let barHeight: CGFloat = 96
    
    private func addTimeToEvent() {
        self.isShowingDatePicker = true
    }
    
    private func removeTimeFromEvent() {
        self.isShowingDatePicker = false
        self.startDate = nil
        self.endDate = nil
    }
    
    var body: some View {
        if isDisplayed {
            VStack {
                HStack {
                    Text("Time")
                        .padding(.horizontal)
                    Spacer()
                    Button(action: { self.removeTimeFromEvent() }) {
                        Text("Remove").foregroundColor(.red1)
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
                Divider()
                    .padding(.horizontal)
                HStack {
                    DatePickerInputView(date: self.$startDate, placeholder: "Start")
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .background(RoundedRectangle(cornerRadius: 4).fill(Color.lightGray1))
                        .onTapGesture {
                            if self.startDate == nil {
                                self.startDate = Date()
                            }
                        }
                    Text("to")
                    DatePickerInputView(date: self.$endDate, placeholder: "End")
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .background(RoundedRectangle(cornerRadius: 4).fill(Color.lightGray1))
                        .onTapGesture {
                            if self.endDate == nil {
                                self.endDate = Date()
                            }
                        }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .frame(width: 362, height: self.barHeight)
            .background(RoundedRectangle(cornerRadius: 13)
                            .fill(Color(uiColor: .systemGray6))
                            .shadow(radius: 4, x: 2, y: 4))
        } else {
            Button(action: self.addTimeToEvent) {
                Text("Add Date")
                    .frame(height: 48)
                    .foregroundColor(Color.blue1)
                    .background(RoundedRectangle(cornerRadius: 13).fill(Color.lightGray2).frame(width: 360, height: 60)
                                    .shadow(radius: 4, x: 2, y: 4))
            }
            .buttonStyle(.plain)
        }
    }
}
