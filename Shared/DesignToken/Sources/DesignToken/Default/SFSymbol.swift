//
//  SFSymbol.swift
//  DesignToken
//

import SwiftUI

/// SF Symbol names used across TimeDraw.
public enum SFSymbol: String {
    case calendar
    case checklist
    case checkmark
    case checkmarkCircleFill = "checkmark.circle.fill"
    case chevronLeft = "chevron.left"
    case chevronRight = "chevron.right"
    case chevronUpChevronDown = "chevron.up.chevron.down"
    case circle
    case ellipsisCircle = "ellipsis.circle"
    case exclamationmarkCircleFill = "exclamationmark.circle.fill"
    case infoCircleFill = "info.circle.fill"
    case plus
    case `repeat` = "repeat"
    case trash
    case trashFill = "trash.fill"
    case xmark
}

public extension Image {
    init(_ symbol: SFSymbol) {
        self.init(systemName: symbol.rawValue)
    }
}
