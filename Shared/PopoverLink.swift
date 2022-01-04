//
//  PopoverLink.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/4/22.
//

import SwiftUI

struct PopoverLink<Label, Destination> : View where Label : View, Destination : View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    private let destination: Destination
    private let label: Label
    private var isActive: Binding<Bool>?
    @State private var internalIsActive = false

    /// Creates an instance that presents `destination`.
    public init(destination: Destination, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.label = label()
    }

    /// Creates an instance that presents `destination` when active.
    public init(destination: Destination, isActive: Binding<Bool>, @ViewBuilder label: () -> Label) {
        self.destination = destination
        self.label = label()
        self.isActive = isActive
    }

    private func popoverButton() -> some View {
        Button {
            (isActive ?? _internalIsActive.projectedValue).wrappedValue = true
        } label: {
            label
        }
    }

    /// The content and behavior of the view.
    public var body: some View {
        if horizontalSizeClass == .compact {
            popoverButton().sheet(isPresented: (isActive ?? _internalIsActive.projectedValue)) {
                destination
            }
        } else {
            popoverButton().popover(isPresented: (isActive ?? _internalIsActive.projectedValue)) {
                destination
            }
        }
    }
}
