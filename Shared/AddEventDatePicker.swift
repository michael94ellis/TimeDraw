//
//  AddEventDatePicker.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/18/22.
//

import SwiftUI

struct AddEventDatePicker: View {
    
    @Binding var startDate: Date?
    @Binding var endDate: Date?
    @Binding var isDisplayed: Bool
    private let barHeight: CGFloat = 96
    
    var body: some View {
        VStack {
            HStack {
                Text("Time")
                    .padding(.horizontal)
                Spacer()
                Button(action: { self.isDisplayed.toggle() }) {
                    Text("Remove").foregroundColor(.red1)
                }
                .padding(.horizontal)
            }
            .padding(.top)
            Divider()
                .padding(.horizontal)
            HStack {
                DatePickerInputView(date: self.$startDate, placeholder: "Start")
                    .padding(.horizontal)
                Text("to")
                DatePickerInputView(date: self.$endDate, placeholder: "End")
                    .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .frame(width: 362, height: self.barHeight)
        .background(RoundedRectangle(cornerRadius: 13)
                        .fill(Color(uiColor: .systemGray6)))
    }
}
