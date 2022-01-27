//
//  UIPickerTextField.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/25/22.
//

import SwiftUI

class UIPickerTextField: UITextField, UIPickerViewDelegate, UIPickerViewDataSource {
    // MARK: - Public properties
    var data: [String]
    @Binding var selectionIndex: Int?

    // MARK: - Initializers
    init(data: [String], selectionIndex: Binding<Int?>) {
        self.data = data
        self._selectionIndex = selectionIndex
        super.init(frame: .zero)
        self.textAlignment = .center
        if let selectionIndex = selectionIndex.wrappedValue {
            self.text = data[selectionIndex]
        }
        self.inputView = pickerView
        self.tintColor = .clear
        let toolBar = UIToolbar()
        toolBar.barTintColor = .systemGray4
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let clearButton = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(self.clearTextField))
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissTextField))
        toolBar.setItems([clearButton, flexibleSpace, doneButton], animated: false)
        inputAccessoryView = toolBar
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private properties
    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()

    // MARK: - Private methods
    @objc
    private func donePressed() {
        self.selectionIndex = self.pickerView.selectedRow(inComponent: 0)
        self.endEditing(true)
    }
    
    // MARK: - UIPickerViewDataSource & UIPickerViewDelegate extension
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.data.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.data[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectionIndex = row
    }
    
    @objc private func clearTextField() {
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
