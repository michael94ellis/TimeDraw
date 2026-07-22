//
//  MultiPicker.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/8/22.
//

import SwiftUI

struct MultiPicker<T: Hashable & CustomStringConvertible>: View {

    var options: [T]
    @Binding var selections: [T]

    init(_ options: [T], selections: Binding<[T]>) {
        self.options = options
        self._selections = selections
    }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(options, id: \.self) { item in
                MultipleSelectionItem(
                    title: String(item.description.prefix(3)),
                    selected: selections.contains(item)
                ) {
                    if selections.contains(item) {
                        selections.removeAll { $0 == item }
                    } else {
                        selections.append(item)
                    }
                }
            }
        }
    }
}

struct MultipleSelectionItem: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    init(title: String, selected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = selected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.interRegular)
                .frame(minWidth: 36, minHeight: 32)
                .padding(.horizontal, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue1.opacity(0.15) : Color(uiColor: .tertiarySystemGroupedBackground))
                )
                .overlay(
                    Capsule()
                        .strokeBorder(isSelected ? Color.blue1 : Color.clear, lineWidth: 1)
                )
                .foregroundStyle(isSelected ? Color.blue1 : Color(uiColor: .label))
        }
        .buttonStyle(.plain)
    }
}
