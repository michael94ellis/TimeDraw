//
//  Colors+watchOS.swift
//  DesignToken
//
//  watchOS-specific semantic color values. watchOS lacks the full set of UIKit
//  system colors used on iOS, so these are drawn from the raw `Palette`.
//

#if os(watchOS)
import SwiftUI

public extension Colors {
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    static let tertiaryText = Color.secondary.opacity(0.7)
    static let listRowBackground = Palette.darkGray2
    static let groupedBackground = Palette.dark
    static let chipBackground = Palette.gray1.opacity(0.35)
    static let systemBackground = Color.black
    static let segmentedPickerTrack = Palette.gray1.opacity(0.45)
    static let calendarDaySelectedBackground = Palette.gray1.opacity(0.55)
    static let recurrenceDaySelectedBackground = Palette.gray1.opacity(0.45)
    static let recurrenceDayDefaultBackground = Palette.darkGray2
    static let clockFaceTickStroke = Palette.gray2.opacity(0.5)
    static let clockFaceAlternateStroke = Palette.gray2.opacity(0.35)
}
#endif
