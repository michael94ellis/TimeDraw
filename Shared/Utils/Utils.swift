//
//  Utils.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/26/22.
//

import Foundation

public var ordinalFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter
}()

extension Int {
    var ordinal: String? {
        return ordinalFormatter.string(from: NSNumber(value: self))
    }
}
