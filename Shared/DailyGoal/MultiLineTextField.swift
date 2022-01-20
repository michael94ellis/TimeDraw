//
//  MultiLineTextField.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/5/22.
//

import SwiftUI
import UIKit

fileprivate struct UITextViewWrapper: UIViewRepresentable {
    typealias UIViewType = UITextView

    @Binding var text: String
    @Binding var calculatedHeight: CGFloat
    var isFocused: FocusState<Bool>.Binding
    var onCommit: (() -> Void)?

    func makeUIView(context: UIViewRepresentableContext<UITextViewWrapper>) -> UITextView {
        let textField = UITextView()
        textField.delegate = context.coordinator
        textField.font = .preferredFont(forTextStyle: .callout)
        textField.isEditable = true
        textField.textAlignment = .center
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.isSelectable = true
        textField.isUserInteractionEnabled = true
        textField.isScrollEnabled = false
        textField.backgroundColor = UIColor.clear
        textField.clipsToBounds = true
        if nil != onCommit {
            textField.returnKeyType = .done
        }
        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: textField.frame.size.width, height: 44))
        let done = SwiftBarButtonItem(title: "Done", style: .done, actionHandler: { _ in
            self.isFocused.wrappedValue.toggle()
        })
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.items = [spacer, done]
        textField.inputAccessoryView = toolBar
        return textField
    }

    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<UITextViewWrapper>) {
        if uiView.text != self.text {
            uiView.text = self.text
        }
        UITextViewWrapper.recalculateHeight(view: uiView, result: $calculatedHeight)
    }

    fileprivate static func recalculateHeight(view: UIView, result: Binding<CGFloat>) {
        let newSize = view.sizeThatFits(CGSize(width: view.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        if result.wrappedValue != newSize.height {
            DispatchQueue.main.async {
                result.wrappedValue = newSize.height // !! must be called asynchronously
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, height: $calculatedHeight, onDone: onCommit)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var calculatedHeight: Binding<CGFloat>
        var onDone: (() -> Void)?

        init(text: Binding<String>, height: Binding<CGFloat>, onDone: (() -> Void)? = nil) {
            self.text = text
            self.calculatedHeight = height
            self.onDone = onDone
        }

        func textViewDidChange(_ uiView: UITextView) {
            text.wrappedValue = uiView.text
            UITextViewWrapper.recalculateHeight(view: uiView, result: calculatedHeight)
        }
    }
}

struct MultilineTextField: View {

    private var placeholder: String
    private var onCommit: (() -> Void)?

    @Binding private var text: String
    private var internalText: Binding<String> {
        Binding<String>(get: { self.text } ) {
            self.text = $0
            self.showingPlaceholder = $0.isEmpty
        }
    }

    @State private var dynamicHeight: CGFloat = 100
    @State private var showingPlaceholder = false
    var isFocused: FocusState<Bool>.Binding

    init (_ placeholder: String = "", text: Binding<String>, focus: FocusState<Bool>.Binding, onCommit: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self.isFocused = focus
        self.onCommit = onCommit
        self._text = text
        self._showingPlaceholder = State<Bool>(initialValue: self.text.isEmpty)
    }

    var body: some View {
        UITextViewWrapper(text: self.internalText, calculatedHeight: self.$dynamicHeight, isFocused: self.isFocused, onCommit: self.onCommit)
            .frame(minHeight: self.dynamicHeight, maxHeight: self.dynamicHeight)
            .background(self.placeholderView, alignment: .center)
    }
    
    @ViewBuilder
    var placeholderView: some View {
        if showingPlaceholder, !isFocused.wrappedValue {
            Text(placeholder)
                .frame(alignment: .center)
                .foregroundColor(.gray)
                .padding(.leading, 4)
                .padding(.top, 8)
        }
    }
}

