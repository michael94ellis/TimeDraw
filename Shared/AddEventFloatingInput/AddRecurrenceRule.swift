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
    @State var showOccurenceEnd: Bool = false
    
    var body: some View {
        if self.viewModel.isRecurrencePickerOpen {
            VStack {
                HStack {
                    Button(action: {
                        withAnimation {
                            self.showOccurenceEnd.toggle()
                        }
                    }) {
                        Text(self.showOccurenceEnd ? "Occurrences" : "Repeat")
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
                    Picker("", selection: self.$viewModel.selectedRule) {
                        ForEach(EKRecurrenceFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.description)
                                .font(.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 4)
                }
                .padding(.horizontal)
                HStack {
                    if self.showOccurenceEnd {
                        Spacer()
                        Text("Repeat")
                        TextField("123", value: self.$viewModel.numberOfOccurences, formatter: NumberFormatter())
                            .frame(width: 90, height: 30)
                            .multilineTextAlignment(TextAlignment.center)
                            .background(RoundedRectangle(cornerRadius: 4).fill(Color(uiColor: .systemGray5)))
                        Text("times")
                        Spacer()
                    } else {
                        Button(action: {
                            withAnimation {
                                self.showDateTime.toggle()
                            }
                        }) {
                            Text(self.showDateTime ?  "End:" : "End Date:")
                                .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                        if self.showDateTime {
                            DatePicker("", selection: self.viewModel.endRecurrenceDateBinding)
                        } else {
                            DateTimePickerInputView(date: self.$viewModel.endRecurrenceDate, placeholder: "Tap to add", mode: .date)
                                .frame(width: 150, height: 30)
                                .background(RoundedRectangle(cornerRadius: 4).fill(Color(uiColor: .systemGray5)))
                                .onTapGesture {
                                    self.viewModel.setSuggestedEndRecurrenceDate()
                                    self.viewModel.recurrenceEnds.toggle()
                                }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .frame(maxWidth: 600)
            .background(RoundedRectangle(cornerRadius: 13)
                            .fill(Color(uiColor: .systemGray6))
                            .shadow(radius: 4, x: 2, y: 4))
            // This is where the recurrence end is set
            .onReceive(self.viewModel.endRecurrenceDate.publisher) {
                self.viewModel.recurrenceRule?.recurrenceEnd = EKRecurrenceEnd(end: $0)
            }
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
