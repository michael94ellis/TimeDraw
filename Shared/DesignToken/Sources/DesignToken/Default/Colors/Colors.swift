//
//  Colors.swift
//  DesignToken
//
//  Created by Michael Ellis on 7/20/26.
//

import SwiftUI

/// Semantic color tokens.
///
/// Members that share the same value across every platform live here in the
/// `Default` folder. Platform-specific values are declared in
/// `iOS/Colors+iOS.swift` and `watchOS/Colors+watchOS.swift` as `#if`-guarded
/// extensions of this enum.
public enum Colors {
    public static let destructive = Palette.red1
    public static let success = Palette.green1
    public static let action = Palette.blue1
    public static let today = Palette.red1

    public static let mutedText = Palette.gray2
    public static let placeholderText = Palette.gray1
    public static let textFieldBorder = Palette.lightGray
    public static let calendarDayText = Palette.darkGray
    public static let calendarExcessDayText = Color.gray

    public static let clockHand = Palette.darkGray
    public static let clockSecondHand = Palette.red1
    public static let completed = Palette.green1

    public static let modalScrim = Color.black.opacity(0.25)
    public static let weekDaySelectionFill = Color.secondary.opacity(0.15)
    public static let segmentedPickerHighlight = Color.gray.opacity(0.4)
    public static let destructiveButtonPressed = Palette.red1.opacity(0.85)
    public static let chipSelectedFill = Palette.blue1.opacity(0.15)
    public static let chipSelectedBorder = Palette.blue1
    public static let chipSelectedForeground = Palette.blue1
    public static let onAccentBackground = Color.white
}
