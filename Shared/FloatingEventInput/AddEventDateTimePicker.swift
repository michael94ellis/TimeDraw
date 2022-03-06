//
//  AddEventDateTimePicker.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/18/22.
//

import SwiftUI

struct AddEventDateTimePicker: View {
    
    @EnvironmentObject var viewModel: ModifyCalendarItemViewModel
    @State var showDates: Bool = true
    private let barHeight: CGFloat = 96
    
    var body: some View {
        if self.viewModel.isDateTimePickerOpen {
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
                VStack {
                    HStack {
                        Spacer()
                        Text("Start:")
                            .frame(width: 75, height: 30, alignment: .leading)
                        Spacer()
                        DateAndTimePickers(dateTime: self.$viewModel.newItemStartTime,
                                           dateDate: self.$viewModel.newItemStartDate,
                                           onTap: {
                            if self.viewModel.newItemStartTime == nil {
                                self.viewModel.newItemStartTime = Date().get(.hour, .minute, .second)
                            }
                            if self.viewModel.newItemStartDate == nil {
                                self.viewModel.newItemStartDate = Date().get(.year, .month, .day)
                            }
                        })
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    HStack {
                        Spacer()
                        Text("End:")
                            .frame(width: 75, height: 30, alignment: .leading)
                        Spacer()
                        DateAndTimePickers(dateTime: self.$viewModel.newItemEndTime,
                                           dateDate: self.$viewModel.newItemEndDate,
                                           onTap: {
                            if self.viewModel.newItemEndTime == nil {
                                self.viewModel.newItemEndTime = Date().get(.hour, .minute, .second)
                            }
                            if self.viewModel.newItemEndDate == nil {
                                self.viewModel.newItemEndDate = Date().get(.year, .month, .day)
                            }
                        })
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom)
                
            }
            .frame(maxWidth: 600)
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
                    .background(RoundedRectangle(cornerRadius: 13).fill(Color(uiColor: .systemGray6))
                                    .shadow(radius: 4, x: 2, y: 4))
            }
            .buttonStyle(.plain)
        }
    }
}
