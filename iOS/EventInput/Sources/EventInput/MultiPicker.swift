//
//  MultiPicker.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/8/22.
//

import DesignToken
import AppCore
import SwiftUI

/// A horizontal row of toggleable chips used to select multiple options (e.g.
/// weekdays for a weekly recurrence).
///
/// Each chip fills an equal share of the available width so the row never
/// overflows its container regardless of how many options are supplied.
struct MultiPicker<T: Hashable & CustomStringConvertible>: View {

    var options: [T]
    @Binding var selections: [T]

    init(_ options: [T], selections: Binding<[T]>) {
        self.options = options
        self._selections = selections
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { item in
                MultipleSelectionItem(
                    title: String(item.description.prefix(3)),
                    selected: selections.contains(item)
                ) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        toggle(item)
                    }
                }
            }
        }
    }

    private func toggle(_ item: T) {
        if selections.contains(item) {
            selections.removeAll { $0 == item }
        } else {
            selections.append(item)
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
                .font(.app(.body))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, minHeight: 34)
                .background(
                    Capsule()
                        .fill(isSelected ? Colors.chipSelectedFill : Colors.chipBackground)
                )
                .overlay(
                    Capsule()
                        .strokeBorder(isSelected ? Colors.chipSelectedBorder : Color.clear, lineWidth: 1)
                )
                .foregroundStyle(isSelected ? Colors.chipSelectedForeground : Colors.primaryText)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
