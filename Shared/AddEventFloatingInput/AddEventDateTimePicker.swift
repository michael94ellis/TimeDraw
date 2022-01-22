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
    let combineDateFormatter = DateFormatter()
    
    var startDateDateBinding: Binding<Date> { Binding<Date>(get: { self.viewModel.newItemStartDate ?? Date() }, set: { self.viewModel.newItemStartDate = $0 }) }
    var endDateDateBinding: Binding<Date> { Binding<Date>(get: { self.viewModel.newItemEndDate ?? Date().addingTimeInterval(60 * 60) }, set: { self.viewModel.newItemEndDate = $0 }) }
    
    func combineDateWithTime(date: Date?, time: Date?) -> Date? {
        let calendar = Calendar.current
        var mergedComponents = DateComponents()
        guard let unwrappedDate = date else {
            return time
        }
        guard let unwrappedTime = time else {
            return date
        }
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: unwrappedDate)
        mergedComponents.year = dateComponents.year
        mergedComponents.month = dateComponents.month
        mergedComponents.day = dateComponents.day
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: unwrappedTime)
        mergedComponents.hour = timeComponents.hour
        mergedComponents.minute = timeComponents.minute
        mergedComponents.second = timeComponents.second
        return calendar.date(from: mergedComponents)
    }
    
    var body: some View {
        if self.viewModel.isTimePickerOpen {
            VStack {
                HStack {
                    Button(action: {
                        withAnimation {
                            self.showDates.toggle()
                        }
                    }) {
                        Text(self.showDates ?  "Date/Time" : "Time")
                            .padding(.horizontal)
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    Button(action: { self.viewModel.removeTimeFromEvent() }) {
                        Text("Remove").foregroundColor(.red1)
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
                Divider()
                    .padding(.horizontal)
                if self.showDates {
                    VStack {
                        DatePicker("From:", selection: self.startDateDateBinding)
                        DatePicker("To:", selection: self.endDateDateBinding)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
                } else {
                    HStack {
                        DateTimePickerInputView(date: self.viewModel.newItemStartDateBinding, placeholder: "Start", mode: .time)
                            .frame(height: 30)
                            .padding(.vertical, 4)
                            .background(RoundedRectangle(cornerRadius: 4).fill(Color(uiColor: .systemGray5)))
                            .onTapGesture {
                                if self.viewModel.newItemStartDate == nil {
                                    self.viewModel.newItemStartDate = Date()
                                }
                            }
                        Text("to")
                        DateTimePickerInputView(date: self.viewModel.newItemEndDateBinding, placeholder: "End", mode: .time)
                            .frame(width: 150, height: 30)
                            .padding(.vertical, 4)
                            .background(RoundedRectangle(cornerRadius: 4).fill(Color(uiColor: .systemGray5)))
                            .onTapGesture {
                                if self.viewModel.newItemEndDate == nil {
                                    self.viewModel.newItemEndDate = Date().addingTimeInterval(60 * 60)
                                }
                            }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
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
                    .background(RoundedRectangle(cornerRadius: 13).fill(Color(uiColor: .systemGray6)).frame(width: 360, height: 60)
                                    .shadow(radius: 4, x: 2, y: 4))
            }
            .buttonStyle(.plain)
        }
    }
}
