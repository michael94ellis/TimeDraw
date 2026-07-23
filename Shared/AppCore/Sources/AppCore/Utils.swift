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
    public var ordinal: String? {
        return ordinalFormatter.string(from: NSNumber(value: self))
    }
}

extension Bundle {
    public var releaseVersionNumber: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    public var buildVersionNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
}

extension Array {
    public func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
