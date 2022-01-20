//
//  DatePickerInputView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/19/22.
//

import SwiftUI

struct DatePickerInputView: UIViewRepresentable {
    
    @Binding var date: Date?
    let placeholder: String
    let formatter = DateFormatter()
    
    init(date: Binding<Date?>, placeholder: String) {
        self._date = date
        self.placeholder = placeholder
        formatter.dateFormat = "MMM dd hh:mm a"
    }
    
    func updateUIView(_ uiView: DatePickerTextField, context: Context) {
        if let date = date {
            uiView.text = "\(formatter.string(from: date))"
        }
    }
    
    func makeUIView(context: Context) -> DatePickerTextField {
        let pickerField = DatePickerTextField(date: $date, frame: .zero)
        pickerField.placeholder = placeholder
        if let date = date {
            pickerField.text = "\(formatter.string(from: date))"
        }
        return pickerField
    }
    
}

final class DatePickerTextField: UITextField {
    @Binding var date: Date?
    private let datePicker = UIDatePicker()
    
    init(date: Binding<Date?>, frame: CGRect) {
        self._date = date
        super.init(frame: frame)
        inputView = datePicker
        datePicker.addTarget(self, action: #selector(datePickerDidSelect(_:)), for: .valueChanged)
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .wheels
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissTextField))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        inputAccessoryView = toolBar
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func datePickerDidSelect(_ sender: UIDatePicker) {
        date = sender.date
    }
    
    @objc private func dismissTextField() {
        resignFirstResponder()
    }
}
