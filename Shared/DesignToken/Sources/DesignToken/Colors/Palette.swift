//
//  Palette.swift
//  DesignToken
//
//  Created by Michael Ellis on 7/20/26.
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

public enum Palette {
    public static let dark = Color(hex: "2D2926")
    public static let darkGray = Color(hex: "46403c")
    public static let darkGray2 = Color(hex: "474747")
    public static let gray1 = Color(hex: "515151")
    public static let gray2 = Color(hex: "74706D")
    public static let lightGray = Color(hex: "B7B7B7")
    public static let lightGray1 = Color(hex: "EEEEEF")
    public static let lightGray2 = Color(hex: "F8F8F8")
    public static let light = Color(hex: "F7F8FC")
    
    public static let green1 = Color(hex: "2BE797")
    public static let green2 = Color(hex: "52F5BO")
    public static let green3 = Color(hex: "7DFFC8")
    public static let green4 = Color(hex: "ABFFDB")
    public static let green5 = Color(hex: "D3FFEC")
    
    public static let yellow1 = Color(hex: "DEEF21")
    public static let yellow2 = Color(hex: "EFFE4C")
    public static let yellow3 = Color(hex: "F4FF7E")
    public static let yellow4 = Color(hex: "F9FFB1")
    public static let yellow5 = Color(hex: "FBFFD0")
    
    public static let orange1 = Color(hex: "FFBC00")
    public static let orange2 = Color(hex: "FFCC3E")
    public static let orange3 = Color(hex: "FFD970")
    public static let orange4 = Color(hex: "FFE8A7")
    public static let orange5 = Color(hex: "FFF0C6")
    
    public static let red1 = Color(hex: "FF5C39")
    public static let red2 = Color(hex: "FF795C")
    public static let red3 = Color(hex: "FF9E89")
    public static let red4 = Color(hex: "FFBBAC")
    public static let red5 = Color(hex: "FFDBD3")
    
    public static let blue1 = Color(hex: "2D83DF")
    public static let blue2 = Color(hex: "51A0F3")
    public static let blue3 = Color(hex: "78B9FE")
    public static let blue4 = Color(hex: "94C6FD")
    public static let blue5 = Color(hex: "C2DFFE")
}

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
    
#if os(iOS)
    public static let primaryText = Color(uiColor: .label)
    public static let secondaryText = Color(uiColor: .secondaryLabel)
    public static let tertiaryText = Color(uiColor: .tertiaryLabel)
    public static let listRowBackground = Color(uiColor: .secondarySystemGroupedBackground)
    public static let groupedBackground = Color(uiColor: .systemGroupedBackground)
    public static let chipBackground = Color(uiColor: .tertiarySystemGroupedBackground)
    public static let systemBackground = Color(uiColor: .systemBackground)
    public static let segmentedPickerTrack = Color(uiColor: .systemGray4)
    public static let calendarDaySelectedBackground = Color(uiColor: .systemGray3)
    public static let recurrenceDaySelectedBackground = Color(uiColor: .systemGray2)
    public static let recurrenceDayDefaultBackground = Color(uiColor: .systemGray6)
    public static let clockFaceTickStroke = Color(uiColor: .systemGray3).opacity(0.5)
    public static let clockFaceAlternateStroke = Color(uiColor: .gray).opacity(0.5)
#elseif os(watchOS)
    public static let primaryText = Color.primary
    public static let secondaryText = Color.secondary
    public static let tertiaryText = Color.secondary.opacity(0.7)
    public static let listRowBackground = Palette.darkGray2
    public static let groupedBackground = Palette.dark
    public static let chipBackground = Palette.gray1.opacity(0.35)
    public static let systemBackground = Color.black
    public static let segmentedPickerTrack = Palette.gray1.opacity(0.45)
    public static let calendarDaySelectedBackground = Palette.gray1.opacity(0.55)
    public static let recurrenceDaySelectedBackground = Palette.gray1.opacity(0.45)
    public static let recurrenceDayDefaultBackground = Palette.darkGray2
    public static let clockFaceTickStroke = Palette.gray2.opacity(0.5)
    public static let clockFaceAlternateStroke = Palette.gray2.opacity(0.35)
#endif
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
