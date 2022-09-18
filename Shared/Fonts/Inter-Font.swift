//
//  Inter-Font.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/13/22.
//

import SwiftUI
import UIKit

extension Font {
    static let interExtraLight = Font.custom("Inter-ExtraLight", size: 18, relativeTo: .body)
    static let interLight = Font.custom("Inter-Light", size: 18, relativeTo: .body)
    static let interThin = Font.custom("Inter-Thin", size: 18, relativeTo: .body)
    static let interMedium = Font.custom("Inter-Medium", size: 18, relativeTo: .body)
    static let interRegular = Font.custom("Inter-Regular", size: 18, relativeTo: .body)
    static let interBold = Font.custom("Inter-Bold", size: 18, relativeTo: .body)
    static let interBlack = Font.custom("Inter-Black", size: 18, relativeTo: .body)
    static let interSemiBold = Font.custom("Inter-SemiBold", size: 18, relativeTo: .body)
    static let interExtraBold = Font.custom("Inter-ExtraBold", size: 18, relativeTo: .body)
    
    // Custom Use Font styles
    static let interClock = Font.custom("Inter-Regular", size: 12, relativeTo: .caption)
    static let interFine = Font.custom("Inter-Light", size: 16, relativeTo: .callout)
    static let interExtraBoldTitle = Font.custom("Inter-ExtraBold", size: 22, relativeTo: .title3)
    static let interTitle = Font.custom("Inter-Regular", size: 28, relativeTo: .title)
    static let interTitle2 = Font.custom("Inter-Regular", size: 24, relativeTo: .title)
    static let interBoldTitle2 = Font.custom("Inter-Bold", size: 24, relativeTo: .title)
}

struct AppFontName {
    static let regular = "Inter-Regular"
    static let bold = "Inter-Bold"
    static let lightAlt = "Inter-Light"
}
//customise font
extension UIFontDescriptor.AttributeName {
    static let nsctFontUIUsage = UIFontDescriptor.AttributeName(rawValue: "NSCTFontUIUsageAttribute")
}

extension UIFont {
    
    @objc class func mySystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.regular, size: size)!
    }
    
    @objc class func myBoldSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.bold, size: size)!
    }
    
    @objc class func myItalicSystemFont(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.lightAlt, size: size)!
    }
    
    @objc convenience init(myCoder aDecoder: NSCoder) {
        guard
            let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor,
            let fontAttribute = fontDescriptor.fontAttributes[.nsctFontUIUsage] as? String else {
                self.init(myCoder: aDecoder)
                return
            }
        var fontName = ""
        switch fontAttribute {
        case "CTFontRegularUsage":
            fontName = AppFontName.regular
        case "CTFontEmphasizedUsage", "CTFontBoldUsage":
            fontName = AppFontName.bold
        case "CTFontObliqueUsage":
            fontName = AppFontName.lightAlt
        default:
            fontName = AppFontName.regular
        }
        self.init(name: fontName, size: fontDescriptor.pointSize)!
    }
    
    class func overrideInitialize() {
        guard self == UIFont.self else { return }
        
        if let systemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:))),
           let mySystemFontMethod = class_getClassMethod(self, #selector(mySystemFont(ofSize:))) {
            method_exchangeImplementations(systemFontMethod, mySystemFontMethod)
        }
        
        if let boldSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:))),
           let myBoldSystemFontMethod = class_getClassMethod(self, #selector(myBoldSystemFont(ofSize:))) {
            method_exchangeImplementations(boldSystemFontMethod, myBoldSystemFontMethod)
        }
        
        if let italicSystemFontMethod = class_getClassMethod(self, #selector(italicSystemFont(ofSize:))),
           let myItalicSystemFontMethod = class_getClassMethod(self, #selector(myItalicSystemFont(ofSize:))) {
            method_exchangeImplementations(italicSystemFontMethod, myItalicSystemFontMethod)
        }
        
        if let initCoderMethod = class_getInstanceMethod(self, #selector(UIFontDescriptor.init(coder:))), // Trick to get over the lack of UIFont.init(coder:))
           let myInitCoderMethod = class_getInstanceMethod(self, #selector(UIFont.init(myCoder:))) {
            method_exchangeImplementations(initCoderMethod, myInitCoderMethod)
        }
    }
}
