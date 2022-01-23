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
    @State var showDateTime: Bool = false
    
    var body: some View {
        if self.viewModel.isRecurrencePickerOpen {
            VStack {
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
                    Button(action: { self.viewModel.closeRecurrencePicker() }) {
                        Text("Remove").foregroundColor(.red1)
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
                Divider()
                    .padding(.horizontal)
                HStack {
                    Spacer()
                    Picker("", selection: self.$viewModel.selectedRule) {
                        ForEach(EKRecurrenceFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.description)
                                .font(.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 4)
                    Spacer()
                }
                .padding(.horizontal)
                HStack {
                    if self.viewModel.isRecurrenceUsingOccurences {
                        Spacer()
                        Text("Repeat")
                        TextField("123", value: self.$viewModel.numberOfOccurences, formatter: NumberFormatter())
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
                        Button(action: {
                            withAnimation {
                                self.showDateTime.toggle()
                            }
                        }) {
                            Text("End Date:")
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        if self.showDateTime {
                            DatePicker("", selection: self.viewModel.endRecurrenceDateBinding)
                                .datePickerStyle(.compact)
                                .labelsHidden()
                                .frame(width: 200, height: 30)
                        } else {
                            DateTimePickerInputView(date: self.$viewModel.endRecurrenceDate, placeholder: "Tap to add", mode: .date)
                                .frame(width: 200, height: 30)
                                .background(RoundedRectangle(cornerRadius: 4).fill(Color(uiColor: .systemGray5)))
                                .onTapGesture {
                                    self.viewModel.setSuggestedEndRecurrenceDate()
                                }
                        }
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
            Button(action: self.viewModel.openRecurrencePicker) {
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
                .background(RoundedRectangle(cornerRadius: 13).fill(Color(uiColor: .systemGray6))
                                .shadow(radius: 4, x: 2, y: 4))
            }
            .buttonStyle(.plain)
        }
    }
}
