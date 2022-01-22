//
//  AddRecurrenceRule.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/20/22.
//

import SwiftUI
import EventKit

struct AddRecurrenceRule: View {
    
    @EnvironmentObject var viewModel: AddEventViewModel
    
    var recurrenceRule: EKRecurrenceRule?
    @State var endDate: Date? = Date().addingTimeInterval(60 * 60 * 24 * 14)
    @State var recurrenceEnds: Bool = false
    @State var selectedRule: EKRecurrenceFrequency = .weekly
    
    var body: some View {
        if self.viewModel.isRecurrencePickerOpen {
            VStack {
                HStack {
                    Text("Repeat")
                        .padding(.horizontal)
                    Spacer()
                    Button(action: { self.viewModel.removeRuleFromEvent() }) {
                        Text("Remove").foregroundColor(.red1)
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
                Divider()
                    .padding(.horizontal)
                HStack {
                    Picker("", selection: self.$selectedRule) {
                        ForEach(EKRecurrenceFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.description)
                                .font(.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 4)
                    .background(RoundedRectangle(cornerRadius: 4).fill(Color.lightGray1))
                    Spacer()
                }
                .padding(.horizontal)
                HStack {
                    Text("End Date:")
                        .padding(.horizontal, 3)
                    if self.recurrenceEnds {
                        DateTimePickerInputView(date: self.$endDate, placeholder: "End Date", mode: .date)
                            .frame(height: 30)
                            .background(RoundedRectangle(cornerRadius: 4).fill(Color.lightGray1))
                    }
                    Toggle("", isOn: self.$recurrenceEnds)
                        .padding(.horizontal)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .frame(width: 362)
            .background(RoundedRectangle(cornerRadius: 13)
                            .fill(Color(uiColor: .systemGray6))
                            .shadow(radius: 4, x: 2, y: 4))
        } else {
            Button(action: self.viewModel.addRuleToEvent) {
                HStack {
                    Image(systemName: "clock.arrow.2.circlepath")
                        .resizable()
                        .frame(width: 25, height: 21)
                    Text("Repeat")
                        .frame(height: 48)
                }
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
