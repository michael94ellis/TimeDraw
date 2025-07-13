//
//  DateTimePickerTextField.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/21/22.
//

import SwiftUI

final class DateTimePickerTextField: UITextField {
    
    @Binding var date: Date?
    private let datePicker = UIDatePicker()
    
    init(placeholderText: String, date: Binding<Date?>, frame: CGRect, mode: UIDatePicker.Mode, minuteInterval: Int) {
        self._date = date
        super.init(frame: frame)
        self.placeholder = placeholderText
        inputView = datePicker
        datePicker.date = date.wrappedValue ?? Date()
        datePicker.addTarget(self, action: #selector(datePickerDidSelect(_:)), for: .valueChanged)
        datePicker.datePickerMode = mode
        datePicker.minuteInterval = minuteInterval
        datePicker.preferredDatePickerStyle = .wheels
        let toolBar = UIToolbar()
        toolBar.barTintColor = .systemGray4
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(self.clearTextField))
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissTextField))
        toolBar.setItems([clearButton, flexibleSpace, doneButton], animated: false)
        inputAccessoryView = toolBar
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func datePickerDidSelect(_ sender: UIDatePicker) {
        date = sender.date
    }
    
    @objc private func clearTextField() {
        self.date = nil
        self.text = nil
    }
    
    @objc private func dismissTextField() {
        resignFirstResponder()
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        false
    }

    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        []
    }

    override func caretRect(for position: UITextPosition) -> CGRect {
        .null
    }
}
