//
//  MyToastView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 7/26/25.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum ToastStyle {
    case success
    case destructive
    case error
    case info

    var iconName: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .destructive: return "trash.fill"
        case .error: return "exclamationmark.circle.fill"
        case .info: return "info.circle.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .success: return .green1
        case .destructive: return .red1
        case .error: return .red1
        case .info: return .blue1
        }
    }

    static func inferred(from message: String) -> ToastStyle {
        let lower = message.lowercased()
        if lower.contains("error") || lower.contains("required") || lower.contains("fail") {
            return .error
        }
        if lower.contains("deleted") {
            return .destructive
        }
        if lower.contains("saved") || lower.contains("created") || lower.contains("completed") {
            return .success
        }
        return .info
    }

    var hapticStyle: UINotificationFeedbackGenerator.FeedbackType? {
        switch self {
        case .success: return .success
        case .destructive, .error: return .warning
        case .info: return nil
        }
    }
}

struct MyToastView: View {
    let message: String
    let style: ToastStyle
    let duration: TimeInterval
    let animationDuration: TimeInterval

    @State private var isVisible = false
    @State private var offsetY: CGFloat = 20

    init(message: String,
         style: ToastStyle = .info,
         duration: TimeInterval = 2.4,
         animationDuration: TimeInterval = 0.3) {
        self.message = message
        self.style = style
        self.duration = duration
        self.animationDuration = animationDuration
    }

    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 10) {
                Image(systemName: style.iconName)
                    .foregroundStyle(style.accentColor)
                Text(message)
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(uiColor: .label))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
            )
            .opacity(isVisible ? 1 : 0)
            .offset(y: offsetY)
            .padding(.horizontal, 24)
            .padding(.bottom, 88)
            .onAppear {
                triggerHapticIfNeeded()
                withAnimation(.easeOut(duration: animationDuration)) {
                    offsetY = 0
                    isVisible = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + (duration - animationDuration)) {
                    withAnimation(.easeIn(duration: animationDuration)) {
                        offsetY = 20
                        isVisible = false
                    }
                }
            }
        }
    }

    private func triggerHapticIfNeeded() {
        #if canImport(UIKit)
        guard let feedback = style.hapticStyle else { return }
        UINotificationFeedbackGenerator().notificationOccurred(feedback)
        #endif
    }
}
