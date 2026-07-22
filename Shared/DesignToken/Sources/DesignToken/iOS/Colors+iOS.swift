//
//  Colors+iOS.swift
//  DesignToken
//
//  iOS-specific semantic color values. These map onto UIKit system colors so
//  the app adapts to light/dark mode automatically.
//

#if os(iOS)
import SwiftUI
import UIKit

public extension Colors {
    static let primaryText = Color(uiColor: .label)
    static let secondaryText = Color(uiColor: .secondaryLabel)
    static let tertiaryText = Color(uiColor: .tertiaryLabel)
    static let listRowBackground = Color(uiColor: .secondarySystemGroupedBackground)
    static let groupedBackground = Color(uiColor: .systemGroupedBackground)
    static let chipBackground = Color(uiColor: .tertiarySystemGroupedBackground)
    static let systemBackground = Color(uiColor: .systemBackground)
    static let segmentedPickerTrack = Color(uiColor: .systemGray4)
    static let calendarDaySelectedBackground = Color(uiColor: .systemGray3)
    static let recurrenceDaySelectedBackground = Color(uiColor: .systemGray2)
    static let recurrenceDayDefaultBackground = Color(uiColor: .systemGray6)
    static let clockFaceTickStroke = Color(uiColor: .systemGray3).opacity(0.5)
    static let clockFaceAlternateStroke = Color(uiColor: .gray).opacity(0.5)
}
#endif
