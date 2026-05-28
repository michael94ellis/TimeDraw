//
//  FormStyles.swift
//  TimeDraw
//

import SwiftUI

struct InsetGroupedBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

extension View {
    func insetGroupedBackground() -> some View {
        modifier(InsetGroupedBackground())
    }
}

struct FormSection<Content: View>: View {
    let title: String?
    let content: Content

    init(_ title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
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
            .insetGroupedBackground()
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
                .foregroundStyle(Color(uiColor: .label))
            Spacer()
            if let value, !value.isEmpty {
                Text(value)
                    .font(.interFine)
                    .foregroundStyle(.secondary)
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

struct FormDivider: View {
    var body: some View {
        Divider()
            .padding(.leading, 16)
    }
}
