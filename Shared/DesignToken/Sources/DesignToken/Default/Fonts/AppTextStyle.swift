//
//  AppTextStyle.swift
//  DesignToken
//

import SwiftUI
import UIKit

/// Every kind of text in the app. Naming follows what the label is, not how it looks.
public enum AppTextStyle: Sendable {
    case headerTitle
    case weekday
    case weekdayEmphasized
    case dayNumber
    case dayNumberSelected
    case dayNumberToday
    case listTitle
    case listSubtitle
    case listCaption
    case listEmpty
    case clockHour
    case body
    case fine
    case button
    case icon
    case iconMedium
    case iconLarge
}

private enum InterWeight: String {
    case light = "Inter-Light"
    case regular = "Inter-Regular"
    case medium = "Inter-Medium"
    case semiBold = "Inter-SemiBold"
    case bold = "Inter-Bold"
    case extraBold = "Inter-ExtraBold"
}

private struct FontSpec {
    let weight: InterWeight
    let phoneSize: CGFloat
    let padSize: CGFloat
    let relativeTo: Font.TextStyle

    func size(for form: DesignForm) -> CGFloat {
        switch form {
        case .phone, .watch: phoneSize
        case .pad: padSize
        }
    }
}

extension AppTextStyle {
    private var spec: FontSpec {
        switch self {
        case .headerTitle: FontSpec(weight: .extraBold, phoneSize: 22, padSize: 34, relativeTo: .title3)
        case .weekday: FontSpec(weight: .light, phoneSize: 18, padSize: 20, relativeTo: .body)
        case .weekdayEmphasized: FontSpec(weight: .semiBold, phoneSize: 18, padSize: 20, relativeTo: .body)
        case .dayNumber: FontSpec(weight: .regular, phoneSize: 18, padSize: 20, relativeTo: .body)
        case .dayNumberSelected: FontSpec(weight: .semiBold, phoneSize: 18, padSize: 20, relativeTo: .body)
        case .dayNumberToday: FontSpec(weight: .bold, phoneSize: 18, padSize: 20, relativeTo: .body)
        case .listTitle: FontSpec(weight: .semiBold, phoneSize: 18, padSize: 20, relativeTo: .body)
        case .listSubtitle: FontSpec(weight: .light, phoneSize: 16, padSize: 18, relativeTo: .callout)
        case .listCaption: FontSpec(weight: .regular, phoneSize: 12, padSize: 13, relativeTo: .caption)
        case .listEmpty: FontSpec(weight: .regular, phoneSize: 18, padSize: 20, relativeTo: .body)
        case .clockHour: FontSpec(weight: .bold, phoneSize: 16, padSize: 26, relativeTo: .caption)
        case .body: FontSpec(weight: .regular, phoneSize: 18, padSize: 20, relativeTo: .body)
        case .fine: FontSpec(weight: .light, phoneSize: 16, padSize: 18, relativeTo: .callout)
        case .button: FontSpec(weight: .semiBold, phoneSize: 18, padSize: 20, relativeTo: .body)
        case .icon: FontSpec(weight: .medium, phoneSize: 17, padSize: 20, relativeTo: .body)
        case .iconMedium: FontSpec(weight: .medium, phoneSize: 22, padSize: 30, relativeTo: .title3)
        case .iconLarge: FontSpec(weight: .regular, phoneSize: 56, padSize: 56, relativeTo: .largeTitle)
        }
    }

    fileprivate func resolved(for form: DesignForm) -> (name: String, size: CGFloat, relativeTo: Font.TextStyle) {
        let s = spec
        return (s.weight.rawValue, s.size(for: form), s.relativeTo)
    }
}

public extension Font {
    static func app(_ style: AppTextStyle, form: DesignForm = .current) -> Font {
        let resolved = style.resolved(for: form)
        return .custom(resolved.name, size: resolved.size, relativeTo: resolved.relativeTo)
    }
}

public extension UIFont {
    static func app(_ style: AppTextStyle, form: DesignForm = .current) -> UIFont {
        let resolved = style.resolved(for: form)
        return UIFont(name: resolved.name, size: resolved.size)
            ?? .systemFont(ofSize: resolved.size)
    }
}
