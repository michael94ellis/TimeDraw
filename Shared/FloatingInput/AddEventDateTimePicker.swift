//
//  AddEventDateTimePicker.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/18/22.
//

import SwiftUI
import EventKit

struct AddEventDateTimePicker: View {
    
    @EnvironmentObject var viewModel: ModifyCalendarItemViewModel
    @State var showDates: Bool = true
    private let barHeight: CGFloat = 96
    
    func setStartTime() {
        let displayDate = EventListViewModel.shared.displayDate
        if self.viewModel.newItemStartTime == nil {
            self.viewModel.newItemStartTime = displayDate.get(.hour, .minute, .second)
        }
        if self.viewModel.newItemStartDate == nil {
            self.viewModel.newItemStartDate = displayDate.get(.year, .month, .day)
        }
    }
    
    func setEndTime() {
        let displayDate = EventListViewModel.shared.displayDate
        if self.viewModel.newItemEndTime == nil {
            self.viewModel.newItemEndTime = Calendar.current.date(byAdding: .hour, value: 1, to: displayDate)?.get(.hour, .minute, .second)
        }
        if self.viewModel.newItemEndDate == nil {
            self.viewModel.newItemEndDate = displayDate.get(.year, .month, .day)
        }
    }
    
    var body: some View {
        if self.viewModel.isDateTimePickerOpen {
            VStack {
                HStack {
                    Text("Time")
                        .padding(.horizontal)
                    Spacer()
                    if !self.viewModel.editMode || self.viewModel.calendarItem as? EKReminder != nil {
                        Button(action: { self.viewModel.removeTimeFromEvent() }) {
                            Text("Remove").foregroundColor(.red1)
                        }
                        .padding(.horizontal)
                    }
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
                                           onTap: { })
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
                                           onTap: { })
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
            .onAppear(perform: {
                self.setStartTime()
                self.setEndTime()
            })
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
