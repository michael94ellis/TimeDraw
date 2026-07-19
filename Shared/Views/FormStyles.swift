//
//  FormStyles.swift
//  TimeDraw
//

import SwiftUI

struct InsetGroupedBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(DesignToken.Colors.listRowBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignToken.CornerRadius.insetGroupedRadius, style: .continuous))
    }
}

extension View {
    func insetGroupedBackground() -> some View {
        modifier(InsetGroupedBackground())
    }
}

struct GlassPanelModifier: ViewModifier {
    var cornerRadius: CGFloat = DesignToken.CornerRadius.eventInputPanelRadius

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(.regular.interactive(), in: shape)
        } else {
            content
                .background(.ultraThinMaterial, in: shape)
                .overlay(shape.strokeBorder(.white.opacity(0.2), lineWidth: 0.5))
                .shadow(color: .black.opacity(0.1), radius: 16, y: 6)
        }
    }
}

extension View {
    func glassPanel(cornerRadius: CGFloat = DesignToken.CornerRadius.eventInputPanelRadius) -> some View {
        modifier(GlassPanelModifier(cornerRadius: cornerRadius))
    }

    @ViewBuilder
    func glassCapsuleChip(tint: Color? = nil) -> some View {
        if let tint {
            background(tint.opacity(0.15), in: Capsule())
                .overlay(Capsule().strokeBorder(tint.opacity(0.25), lineWidth: 0.5))
        } else {
            background(.thinMaterial, in: Capsule())
        }
    }

    @ViewBuilder
    func glassSubmitButton(tint: Color) -> some View {
        background(tint, in: Circle())
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
                .foregroundStyle(isExpanded ? DesignToken.Colors.primaryText : DesignToken.Colors.tertiaryText)
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

struct FormDivider: View {
    var subtle: Bool = false

    var body: some View {
        Divider()
            .opacity(subtle ? 0.35 : 1)
            .padding(.leading, 16)
    }
}
