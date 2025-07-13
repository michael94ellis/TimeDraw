//
//  DateTimePickerInputView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/19/22.
//

import SwiftUI

struct DateTimePickerInputView: UIViewRepresentable {
    
    @EnvironmentObject private var appSettings: AppSettings
    @Binding var date: Date?
    let placeholder: String
    let formatter = DateFormatter()
    let mode: UIDatePicker.Mode
    
    init(date: Binding<Date?>, placeholder: String, mode: UIDatePicker.Mode, format: String? = nil) {
        self._date = date
        self.placeholder = "\(placeholder)"
        formatter.dateFormat = format == nil ? "MMM dd hh:mm a" : format
        self.mode = mode
    }
    
    func makeUIView(context: Context) -> DateTimePickerTextField {
        let pickerField = DateTimePickerTextField(placeholderText: self.placeholder, date: $date, frame: .zero, mode: self.mode, minuteInterval: appSettings.timePickerGranularity)
        pickerField.textAlignment = .center
        if let date = date {
            pickerField.text = "\(formatter.string(from: date))"
        }
        return pickerField
    }
    
    func updateUIView(_ uiView: DateTimePickerTextField, context: Context) {
        if let unwrappedDate = date {
            uiView.text = "\(formatter.string(from: unwrappedDate))"
            if let datePicker = uiView.inputView as? UIDatePicker {
                datePicker.date = unwrappedDate
            }
        }
    }
}
