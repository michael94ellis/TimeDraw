//
//  Colors.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/2/22.
//

import SwiftUI

extension Color {
    // App White, Gray, Black, Light/Dark colors
    static let dark: Color = Color(hex: "2D2926")
    static let darkGray: Color = Color(hex: "46403c")
    static let darkGray2: Color = Color(hex: "474747")
    static let gray1: Color = Color(hex: "515151")
    static let gray2: Color = Color(hex: "74706D")
    static let lightGray: Color = Color(hex: "B7B7B7")
    static let lightGray1: Color = Color(hex: "EEEEEF")
    static let lightGray2: Color = Color(hex: "F8F8F8")
    static let light: Color = Color(hex: "F7F8FC")
    // Green
    static let green1: Color = Color(hex: "2BE797")
    static let green2: Color = Color(hex: "52F5BO")
    static let green3: Color = Color(hex: "7DFFC8")
    static let green4: Color = Color(hex: "ABFFDB")
    static let green5: Color = Color(hex: "D3FFEC")
    // Yellow
    static let yellow1: Color = Color(hex: "DEEF21")
    static let yellow2: Color = Color(hex: "EFFE4C")
    static let yellow3: Color = Color(hex: "F4FF7E")
    static let yellow4: Color = Color(hex: "F9FFB1")
    static let yellow5: Color = Color(hex: "FBFFD0")
    // Orange
    static let orange1: Color = Color(hex: "FFBC00")
    static let orange2: Color = Color(hex: "FFCC3E")
    static let orange3: Color = Color(hex: "FFD970")
    static let orange4: Color = Color(hex: "FFE8A7")
    static let orange5: Color = Color(hex: "FFF0C6")
    // Red
    static let red1: Color = Color(hex: "FF5C39")
    static let red2: Color = Color(hex: "FF795C")
    static let red3: Color = Color(hex: "FF9E89")
    static let red4: Color = Color(hex: "FFBBAC")
    static let red5: Color = Color(hex: "FFDBD3")
    // Blue
    static let blue1: Color = Color(hex: "2D83DF")
    static let blue2: Color = Color(hex: "51A0F3")
    static let blue3: Color = Color(hex: "78B9FE")
    static let blue4: Color = Color(hex: "94C6FD")
    static let blue5: Color = Color(hex: "C2DFFE")
    
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
