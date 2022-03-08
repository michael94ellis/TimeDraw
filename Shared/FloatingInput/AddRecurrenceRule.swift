//
//  AddRecurrenceRule.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/20/22.
//

import SwiftUI
import EventKit

struct AddRecurrenceRule: View {
    
    @EnvironmentObject var viewModel: ModifyCalendarItemViewModel
    
    var selectedRecurrenceRuleBinding: Binding<EKRecurrenceFrequency> { Binding<EKRecurrenceFrequency>(get: { self.viewModel.selectedRule }, set: { self.viewModel.selectedRule = $0 })}
    
    var unselectedButton: some View {
        Button(action: self.viewModel.openRecurrencePicker) {
            HStack {
                Image(systemName: "repeat")
                    .resizable()
                    .frame(width: 25, height: 21)
                Text("Repeat")
                    .frame(height: 48)
            }
            .frame(maxWidth: 600)
            .frame(height: 48)
            .foregroundColor(Color.blue1)
            .contentShape(Rectangle())
            .background(RoundedRectangle(cornerRadius: 13).fill(Color(uiColor: .systemGray6))
                            .shadow(radius: 4, x: 2, y: 4))
        }
        .buttonStyle(.plain)
    }
    
    var header: some View {
        HStack {
            Button(action: {
                withAnimation {
                    self.viewModel.isRecurrenceUsingOccurences.toggle()
                }
            }) {
                Text(self.viewModel.isRecurrenceUsingOccurences ? "Occurrences" : "Repeat")
                    .padding(.horizontal)
            }
            .buttonStyle(.plain)
            Spacer()
            Button(action: { self.viewModel.removeRecurrenceFromEvent() }) {
                Text("Remove").foregroundColor(.red1)
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
    
    var rulePicker: some View {
        HStack {
            Spacer()
            Picker("", selection: self.$viewModel.selectedRule) {
                ForEach([EKRecurrenceFrequency.daily, .weekly, .monthly, .yearly], id: \.self) { frequency in
                    Text(frequency.description)
                        .font(.title)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 4)
            Spacer()
        }
        .padding(.horizontal)
    }
    @State var dayFrequencyText: String = ""
    func dayFrequencyTextField(_ label: String) -> some View {
        HStack {
            Spacer()
            Text(label)
            TextField("", text: self.$dayFrequencyText)
                .keyboardType(.numberPad)
                .frame(width: 90, height: 30)
                .multilineTextAlignment(TextAlignment.center)
                .background(RoundedRectangle(cornerRadius: 4).fill(Color(uiColor: .systemGray5)))
                .onChange(of: self.dayFrequencyText, perform: { newText in
                    if let intValue = Int(newText) {
                        self.viewModel.frequencyDayValueInt = intValue
                    }
                })
            Spacer()
        }
        .frame(height: 33)
    }
    
    var body: some View {
        if self.viewModel.isRecurrencePickerOpen {
            VStack {
                self.header
                Divider()
                    .padding(.horizontal)
                self.rulePicker
                switch self.viewModel.selectedRule {
                case .daily:
                    HStack {
                        Spacer()
                        Text("Every")
                        TextField("1", value: self.$viewModel.frequencyDayValueInt, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .frame(width: 90, height: 30)
                            .multilineTextAlignment(TextAlignment.center)
                            .background(RoundedRectangle(cornerRadius: 4).fill(Color(uiColor: .systemGray5)))
                            .onChange(of: self.viewModel.frequencyDayValueInt) { newNumber in
                                if newNumber != nil {
                                    self.viewModel.endRecurrenceDate = nil
                                }
                            }
                        Text("Days")
                        Spacer()
                    }
                    .frame(height: 33)
                case .weekly:
                    HStack {
                        Picker("", selection: self.$viewModel.frequencyWeekdayValue) { // S M T W T F S
                            ForEach(EKWeekday.allCases, id: \.self) { day in
                                Text(day.description.prefix(3))
                                    .font(.callout)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 12)
                    }
                    .frame(height: 33)
                case .monthly:
                    self.dayFrequencyTextField("On Day:")
                case .yearly:
                    HStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("Every:")
                            PickerField("Month", data: Calendar.current.monthSymbols, selectionIndex: self.$viewModel.frequencyMonthDate)
                                .frame(width: 90, height: 30)
                                .multilineTextAlignment(TextAlignment.center)
                                .background(RoundedRectangle(cornerRadius: 4).fill(Color(uiColor: .systemGray5)))
                        }
                        .frame(height: 33)
                        self.dayFrequencyTextField("On:")
                        Spacer()
                    }
                @unknown default:
                    EmptyView()
                }
                HStack {
                    if self.viewModel.isRecurrenceUsingOccurences {
                        Spacer()
                        Text("Repeat")
                        TextField("123", value: self.$viewModel.numberOfOccurences, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .frame(width: 90, height: 30)
                            .multilineTextAlignment(TextAlignment.center)
                            .background(RoundedRectangle(cornerRadius: 4).fill(Color(uiColor: .systemGray5)))
                            .onChange(of: self.viewModel.numberOfOccurences) { newNumber in
                                if newNumber != nil {
                                    self.viewModel.endRecurrenceDate = nil
                                }
                            }
                        Text("times")
                        Spacer()
                    } else {
                        Spacer()
                        Text("End Date:  ")
                        DateAndTimePickers(dateTime: self.$viewModel.endRecurrenceTime, dateDate: self.$viewModel.endRecurrenceDate, onTap: {
                            self.viewModel.setSuggestedEndRecurrenceDate()
                        })
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .frame(maxWidth: 600)
            .background(RoundedRectangle(cornerRadius: 13)
                            .fill(Color(uiColor: .systemGray6))
                            .shadow(radius: 4, x: 2, y: 4))
        } else {
            self.unselectedButton
        }
    }
}
