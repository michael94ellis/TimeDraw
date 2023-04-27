//
//  ClockFace.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/16/22.
//

import SwiftUI

struct ClockFace: View {
    
    let width: CGFloat
    static let hours = (0..<60).filter({ $0 % 5 == 0 })
    static let quarterHours: [Double] = {
        var calculatedQuarterHourDegrees: [Double] = []
        hours.forEach({ calculatedQuarterHourDegrees.append(contentsOf: [Double($0) + 1.33, Double($0) + 2.55, Double($0) + 3.69])})
        return calculatedQuarterHourDegrees
    }()
    var body: some View {
        // Dial Background Border
        Circle()
        #if !os(watchOS)
            .strokeBorder(Color(uiColor: .systemGray3), lineWidth: 24)
        #elseif os(watchOS)
            .strokeBorder(Color(uiColor: .gray), lineWidth: 22)
        #endif
            .frame(width: self.width * 2.2, height: self.width * 2.2)
        // Clock Face Markings
        ForEach(ClockFace.hours, id: \.self) { i in
            // Clock Nums
            let num = (i / 5) + 6
            Text("\(num > 12 ? num - 12 : num)")
                .font(.interFine)
                .rotationEffect(.degrees(Double(((num-12)) * -30) - 180))
                .offset(y: self.width * 0.95)
                .rotationEffect(Angle(degrees: Double(i) * 6))
        }
        ForEach(ClockFace.quarterHours, id: \.self) { i in
            // Clock Tick Marks for 15 minute intervals between hours
            Circle()
                .fill(Color.primary)
                .frame(width: 2, height: 2)
                .offset(y: self.width * 0.95)
                .rotationEffect(.init(degrees: Double(i) * 6))
        }
    }
}
