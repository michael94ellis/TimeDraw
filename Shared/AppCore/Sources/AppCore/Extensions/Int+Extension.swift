//
//  Int+Extension.swift
//  AppCore
//
//  Created by Michael Ellis on 7/23/26.
//

import Foundation

extension Int {
    public var ordinal: String? {
        return NumberFormatter.ordinalFormatter.string(from: NSNumber(value: self))
    }
}
