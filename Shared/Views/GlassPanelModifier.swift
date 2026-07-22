//
//  GlassPanelModifier.swift
//  TimeDraw
//
//  Created by Michael Ellis on 7/21/26.
//

import DesignToken
import SwiftUI

struct GlassPanelModifier: ViewModifier {
    var cornerRadius: CGFloat = CornerRadius.eventInputPanelRadius

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }
    
    @ViewBuilder
    func nonGlassContent(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: shape)
            .overlay(shape.strokeBorder(.white.opacity(0.2), lineWidth: 0.5))
            .shadow(color: .black.opacity(0.1), radius: 16, y: 6)
    }

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(.regular.interactive(), in: shape)
        } else {
            nonGlassContent(content: content)
        }
    }
}
