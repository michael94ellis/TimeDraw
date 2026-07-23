//
//  NumberFormatter+Extension.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/26/22.
//

import Foundation

extension NumberFormatter {
    public static var ordinalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter
    }()
    
}
