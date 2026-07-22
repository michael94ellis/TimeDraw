//
//  DesignTokenFonts.swift
//  DesignToken
//

import CoreText
import Foundation

public enum DesignTokenFonts {
    private static let fontNames = [
        "Inter-Black",
        "Inter-Bold",
        "Inter-ExtraBold",
        "Inter-ExtraLight",
        "Inter-Light",
        "Inter-Medium",
        "Inter-Regular",
        "Inter-SemiBold",
        "Inter-Thin",
    ]

    /// Registers Inter fonts from this package's bundle. Call once at app launch
    /// before using Inter fonts or calling `UIFont.overrideInitialize()`.
    public static func register() {
        for name in fontNames {
            guard let url = Bundle.module.url(forResource: name, withExtension: "ttf") else {
                continue
            }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}
