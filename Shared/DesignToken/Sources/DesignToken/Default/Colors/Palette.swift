//
//  Palette.swift
//  DesignToken
//
//  Created by Michael Ellis on 7/20/26.
//

import SwiftUI

/// Raw, platform-independent color values. Prefer referencing semantic tokens
/// in `Colors` over these raw values in feature code.
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
