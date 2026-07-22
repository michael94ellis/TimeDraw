//
//  FormStyles.swift
//  TimeDraw
//

import DesignToken
import SwiftUI

struct InsetGroupedBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Colors.listRowBackground)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.insetGroupedRadius, style: .continuous))
    }
}

extension View {
    func insetGroupedBackground() -> some View {
        modifier(InsetGroupedBackground())
    }
}

struct FormSection<Content: View>: View {
    let title: String?
    let useGroupedBackground: Bool
    let content: Content

    init(_ title: String? = nil, useGroupedBackground: Bool = true, @ViewBuilder content: () -> Content) {
        self.title = title
        self.useGroupedBackground = useGroupedBackground
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title {
                Text(title)
                    .font(.interSemiBold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
            }
            VStack(spacing: 0) {
                content
            }
            .modifier(GroupedBackgroundIfNeeded(enabled: useGroupedBackground))
        }
    }
}

private struct GroupedBackgroundIfNeeded: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.insetGroupedBackground()
        } else {
            content
        }
    }
}

struct SummaryRowLabel: View {
    let title: String
    var value: String?
    var isExpanded: Bool = false

    var body: some View {
        HStack {
            Text(title)
                .font(.interRegular)
                .foregroundStyle(isExpanded ? Colors.primaryText : Colors.tertiaryText)
            Spacer()
            if let value, !value.isEmpty {
                Text(value)
                    .font(.interFine)
                    .foregroundStyle(isExpanded ? .secondary : .tertiary)
                    .lineLimit(1)
            }
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }
}

struct DestructiveTextButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(role: .destructive, action: action) {
            Text(title)
                .font(.interRegular)
        }
    }
}
