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
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.darkGray.opacity(0.2)))
    }
}

struct MultipleSelectionItem: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
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
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(self.isSelected ? (self.colorScheme == .dark ? Color.lightGray2.opacity(0.3) : Color.gray2.opacity(0.3)) : Color.clear)
                        .if(self.isSelected) { view in
                            view.shadow(color: Color.darkGray,radius: 1, x: 0, y: 0)
                                .shadow(color: Color.white, radius: 1, x: 0, y: 0)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 8)
                                )
                        }
                )
        }
        .buttonStyle(.plain)
    }
}
