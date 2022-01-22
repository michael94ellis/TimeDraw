//
//  DateTimePickerInputView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/19/22.
//

import SwiftUI

struct DateTimePickerInputView: UIViewRepresentable {
    
    @Binding var date: Date?
    let placeholder: String
    let formatter = DateFormatter()
    let mode: UIDatePicker.Mode
    
    init(date: Binding<Date?>, placeholder: String, mode: UIDatePicker.Mode) {
        self._date = date
        self.placeholder = placeholder
        formatter.dateFormat = "MMM dd hh:mm a"
        self.mode = mode
    }
    
    func updateUIView(_ uiView: DateTimePickerTextField, context: Context) {
        if let date = date {
            uiView.text = "\(formatter.string(from: date))"
        }
    }
    
    func makeUIView(context: Context) -> DateTimePickerTextField {
        let pickerField = DateTimePickerTextField(date: $date, frame: .zero, mode: self.mode)
        pickerField.placeholder = placeholder
        if let date = date {
            pickerField.text = "\(formatter.string(from: date))"
        }
        return pickerField
    }
    
}
