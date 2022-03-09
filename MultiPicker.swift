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
        print(options)
        self._selections = selections
    }
    
    var body: some View {
        HStack(spacing: 1) {
            ForEach(self.options, id: \.self) { item in
                MultipleSelectionItem(title: String(item.description.prefix(3)),
                                      selected: self.selections.contains(item)) {
                    if self.selections.contains(item) {
                        self.selections.removeAll(where: { $0 == item })
                    }
                    else {
                        self.selections.append(item)
                    }
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(uiColor: .systemGray6)))
    }
}

struct MultipleSelectionItem: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    init(title: String, selected: Bool, action: @escaping () -> ()) {
        self.title = title
        self.isSelected = selected
        self.action = action
    }

    var body: some View {
        Button(action: self.action) {
            Text(self.title)
                .frame(width: 40, height: 32)
                .padding(.horizontal, 4)
                .background(RoundedRectangle(cornerRadius: 8).fill(self.isSelected ? Color(uiColor: .systemGray4) : Color.clear))
        }
        .buttonStyle(.plain)
    }
}
