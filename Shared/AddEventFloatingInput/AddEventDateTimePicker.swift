//
//  AddEventDateTimePicker.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/18/22.
//

import SwiftUI

struct AddEventDateTimePicker: View {
    
    @EnvironmentObject var viewModel: AddEventViewModel
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
                            DateAndTimePickers(suggestTimeInterval: 0, dateTime: self.$viewModel.newItemStartDate)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        HStack {
                            Spacer()
                            Text("End:")
                                .frame(width: 75, height: 30, alignment: .leading)
                            Spacer()
                            DateAndTimePickers(suggestTimeInterval: 60 * 60, dateTime: self.$viewModel.newItemEndDate)
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
