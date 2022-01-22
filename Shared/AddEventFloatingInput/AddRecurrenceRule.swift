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
    @State var endDate: Date?
    @State var showDateTime: Bool = false
    @State var recurrenceEnds: Bool = false
    @State var selectedRule: EKRecurrenceFrequency = .weekly
    
    var endDateBinding: Binding<Date> { Binding<Date>(get: { self.endDate ?? self.setSuggestedEndDate() }, set: { self.endDate = $0 }) }
    
    @discardableResult
    func setSuggestedEndDate() -> Date {
        guard let endDate = self.endDate else {
            var suggestedEndDate: Date
            switch self.selectedRule {
            case .daily: suggestedEndDate = Date().addingTimeInterval(60 * 60 * 24 * 31)
            case .weekly: suggestedEndDate = Date().addingTimeInterval(60 * 60 * 24 * 7 * 4)
            case .monthly: suggestedEndDate = Date().addingTimeInterval(60 * 60 * 24 * 30 * 12)
            case .yearly: suggestedEndDate = Date().addingTimeInterval(60 * 60 * 24 * 365 * 2)
            default: suggestedEndDate = Date().addingTimeInterval(60 * 60 * 24 * 5)
            }
            self.endDate = suggestedEndDate
            return suggestedEndDate
        }
        return endDate
    }
    
    var body: some View {
        if self.viewModel.isRecurrencePickerOpen {
            VStack {
                HStack {
                    Text("Repeat")
                        .padding(.horizontal)
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
                    Picker("", selection: self.$selectedRule) {
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
                        DatePicker("", selection: self.endDateBinding)
                    } else {
                        DateTimePickerInputView(date: self.$endDate, placeholder: "Tap to add", mode: .date)
                            .frame(width: 150, height: 30)
                            .background(RoundedRectangle(cornerRadius: 4).fill(Color(uiColor: .systemGray5)))
                            .onTapGesture {
                                self.setSuggestedEndDate()
                                self.recurrenceEnds.toggle()
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .frame(width: 362)
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
                .background(RoundedRectangle(cornerRadius: 13).fill(Color(uiColor: .systemGray6)).frame(width: 360, height: 60)
                                .shadow(radius: 4, x: 2, y: 4))
            }
            .buttonStyle(.plain)
        }
    }
}