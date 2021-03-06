//
//  SegmentedPickr.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/13/22.
//

import SwiftUI

public struct SegmentedPicker<T: Equatable, Content: View>: View {
    
    @Namespace private var selectionAnimation
    @Binding var selectedItem: T?
    private let items: [T]
    private let content: (T) -> Content
    @State var dragPosition: CGFloat = .zero
    private var itemPositions: [CGFloat] = []

    public init(_ items: [T],
                selectedItem: Binding<T?>,
                @ViewBuilder content: @escaping (T) -> Content) {
        self.items = items
        self._selectedItem = selectedItem
        self.content = content
    }
    
    @ViewBuilder func overlay(for item: T) -> some View {
        if item == selectedItem {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.4))
                .padding(2)
                .matchedGeometryEffect(id: "selectedSegmentHighlight", in: self.selectionAnimation)
                .offset(x: self.dragPosition)
                .gesture(DragGesture().onChanged({ dragChange in
                    self.dragPosition = dragChange.translation.width
                }).onEnded({ dragEnd in
                    withAnimation(.linear) {
                        self.dragPosition = .zero
                    }
                }))

        }
    }

    public var body: some View {
        HStack {
            ForEach(self.items.indices, id: \.self) { index in
                Button(action: {
                    withAnimation(.linear) {
                        self.dragPosition = .zero
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
