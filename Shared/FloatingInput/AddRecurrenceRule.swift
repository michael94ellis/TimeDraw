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
    @State var frequencyMonthDateAdaptor: Int? {
        didSet {
            if let frequencyMonthDateAdaptor = frequencyMonthDateAdaptor {
                self.viewModel.frequencyMonthDate = frequencyMonthDateAdaptor - 1
            }
        }
    }
    
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
            .foregroundColor(Color.blue1)
            .frame(height: 48)
            .frame(maxWidth: 600)
            .background(RoundedRectangle(cornerRadius: 13).fill(Color(uiColor: .systemGray6))
                            .shadow(radius: 4, x: 2, y: 4))
        }
        .contentShape(Rectangle())
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
    
    var rulePickerBinding: Binding<String?> {
        Binding<String?>(get: { self.viewModel.selectedRule.description }, set: { newRule in
            self.viewModel.selectedRule = EKRecurrenceFrequency.allCases.first(where: { $0.description == newRule }) ?? .daily })
    }
    
    var rulePicker: some View {
        SegmentedPicker(EKRecurrenceFrequency.allCases.compactMap({ $0.description }),
                        selectedItem: self.rulePickerBinding,
                        content: { item in
            Text(item)
                .font(.interRegular)
                .padding(.horizontal)
                .padding(.vertical, 4)
        })
    }
    
    func dayFrequencyTextField(_ label: String) -> some View {
        HStack {
            Spacer()
            Text(label)
            TextField("", text: self.$viewModel.dayFrequencyText)
                .keyboardType(.numberPad)
                .frame(width: 90, height: 30)
                .multilineTextAlignment(TextAlignment.center)
                .background(RoundedRectangle(cornerRadius: 4).fill(Color(uiColor: .systemGray5)))
                .onChange(of: self.viewModel.dayFrequencyText, perform: { newText in
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
                    .frame(height: 40)
                    .padding(.bottom, 10)
                case .weekly:
                    MultiPicker(EKWeekday.allCases, selections: self.$viewModel.frequencyWeekdayValues)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(uiColor: .systemGray3))
                                        .shadow(radius: 4, x: 2, y: 4))
                    .frame(height: 40)
                    .padding(.bottom, 10)
                case .monthly:
                    CalendarMultiDateSelection(selectedDates: self.$viewModel.selectedMonthDays)
                case .yearly:
                    HStack {
                        Text("Every:")
                        PickerField("Month", data: Calendar.current.monthSymbols, selectionIndex: self.$viewModel.frequencyMonthDate)
                            .frame(width: 90, height: 30)
                            .multilineTextAlignment(TextAlignment.center)
                            .background(RoundedRectangle(cornerRadius: 4).fill(Color(uiColor: .systemGray5)))
                    }
                    CalendarMultiDateSelection(selectedDates: self.$viewModel.selectedMonthDays)
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
            .background(RoundedRectangle(cornerRadius: 13)
                            .fill(Color(uiColor: .systemGray6))
                            .shadow(radius: 4, x: 2, y: 4))
        } else {
            self.unselectedButton
        }
    }
}
