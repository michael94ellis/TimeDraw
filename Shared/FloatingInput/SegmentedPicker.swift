//
//  SegmentedPickr.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/13/22.
//

import SwiftUI

public struct SegmentedPicker<T: Equatable, Content: View>: View {
    
    @Namespace private var selectionAnimation
    @State var selectedItem: T?
    private let items: [T]
    private let content: (T) -> Content

    public init(_ items: [T],
                selectedIndex: Binding<Int>,
                @ViewBuilder content: @escaping (T) -> Content) {
        self.items = items
        self.content = content
    }
    
    @ViewBuilder func overlay(for item: T) -> some View {
        if item == selectedItem {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.4))
                .matchedGeometryEffect(id: "selectedSegmentHighlight", in: self.selectionAnimation)

        }
    }

    public var body: some View {
        HStack {
            ForEach(self.items.indices, id: \.self) { index in
                Button(action: {
                    withAnimation(.linear) {
                        self.selectedItem = self.items[index]
                    }
                },
                       label: { self.content(self.items[index]) })
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .overlay(self.overlay(for: self.items[index]))
            }
        }
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(uiColor: .systemGray4))
                        .shadow(radius: 4, x: 2, y: 4))
    }
}
