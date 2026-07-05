//
//  DesignTokens.swift
//  TimeDraw
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

enum DesignToken {
    enum CornerRadius {
        static let listRowRadius: CGFloat = 12
        static let insetGroupedRadius: CGFloat = 10
        static let weekDaySelectionRadius: CGFloat = 10
        static let segmentedPickerRadius: CGFloat = 10
        static let segmentedPickerTrackRadius: CGFloat = 8
        static let calendarDayRadius: CGFloat = 8
        static let textFieldRadius: CGFloat = 4
        static let calendarColorBarRadius: CGFloat = 2
        static let eventInputPanelRadius: CGFloat = 13
        static let clockHandRadius: CGFloat = 24
    }

    enum Palette {
        static let dark = Color(hex: "2D2926")
        static let darkGray = Color(hex: "46403c")
        static let darkGray2 = Color(hex: "474747")
        static let gray1 = Color(hex: "515151")
        static let gray2 = Color(hex: "74706D")
        static let lightGray = Color(hex: "B7B7B7")
        static let lightGray1 = Color(hex: "EEEEEF")
        static let lightGray2 = Color(hex: "F8F8F8")
        static let light = Color(hex: "F7F8FC")

        static let green1 = Color(hex: "2BE797")
        static let green2 = Color(hex: "52F5BO")
        static let green3 = Color(hex: "7DFFC8")
        static let green4 = Color(hex: "ABFFDB")
        static let green5 = Color(hex: "D3FFEC")

        static let yellow1 = Color(hex: "DEEF21")
        static let yellow2 = Color(hex: "EFFE4C")
        static let yellow3 = Color(hex: "F4FF7E")
        static let yellow4 = Color(hex: "F9FFB1")
        static let yellow5 = Color(hex: "FBFFD0")

        static let orange1 = Color(hex: "FFBC00")
        static let orange2 = Color(hex: "FFCC3E")
        static let orange3 = Color(hex: "FFD970")
        static let orange4 = Color(hex: "FFE8A7")
        static let orange5 = Color(hex: "FFF0C6")

        static let red1 = Color(hex: "FF5C39")
        static let red2 = Color(hex: "FF795C")
        static let red3 = Color(hex: "FF9E89")
        static let red4 = Color(hex: "FFBBAC")
        static let red5 = Color(hex: "FFDBD3")

        static let blue1 = Color(hex: "2D83DF")
        static let blue2 = Color(hex: "51A0F3")
        static let blue3 = Color(hex: "78B9FE")
        static let blue4 = Color(hex: "94C6FD")
        static let blue5 = Color(hex: "C2DFFE")
    }

    enum Colors {
        static let destructive = Palette.red1
        static let success = Palette.green1
        static let action = Palette.blue1
        static let today = Palette.red1

        static let mutedText = Palette.gray2
        static let placeholderText = Palette.gray1
        static let textFieldBorder = Palette.lightGray
        static let calendarDayText = Palette.darkGray
        static let calendarExcessDayText = Color.gray

        static let clockHand = Palette.darkGray
        static let clockSecondHand = Palette.red1
        static let completed = Palette.green1

        static let modalScrim = Color.black.opacity(0.25)
        static let weekDaySelectionFill = Color.secondary.opacity(0.15)
        static let segmentedPickerHighlight = Color.gray.opacity(0.4)
        static let destructiveButtonPressed = Palette.red1.opacity(0.85)
        static let chipSelectedFill = Palette.blue1.opacity(0.15)
        static let chipSelectedBorder = Palette.blue1
        static let chipSelectedForeground = Palette.blue1
        static let onAccentBackground = Color.white

        #if os(iOS)
        static let primaryText = Color(uiColor: .label)
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
        #elseif os(watchOS)
        static let primaryText = Color.primary
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
        #else
        static let primaryText = Color.primary
        static let listRowBackground = Color.secondary.opacity(0.2)
        static let groupedBackground = Color.clear
        static let chipBackground = Color.secondary.opacity(0.15)
        static let systemBackground = Color.clear
        static let segmentedPickerTrack = Color.gray.opacity(0.4)
        static let calendarDaySelectedBackground = Color.gray.opacity(0.5)
        static let recurrenceDaySelectedBackground = Color.gray.opacity(0.4)
        static let recurrenceDayDefaultBackground = Color.gray.opacity(0.15)
        static let clockFaceTickStroke = Color.gray.opacity(0.5)
        static let clockFaceAlternateStroke = Color.gray.opacity(0.35)
        #endif
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
