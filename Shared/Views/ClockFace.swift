//
//  ClockFace.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/16/22.
//

import SwiftUI

struct ClockFace: View {
    
    let width: CGFloat
    let clockFaceOutlineWidth: CGFloat
    static let hours = (0..<60).filter({ $0 % 5 == 0 })
    static let quarterHours: [Double] = {
        var calculatedQuarterHourDegrees: [Double] = []
        hours.forEach({ calculatedQuarterHourDegrees.append(contentsOf: [Double($0) + 1, Double($0) + 2, Double($0) + 3, Double($0) + 4])})
        return calculatedQuarterHourDegrees
    }()
    
    var clockMarkOffset: CGFloat { (self.width / 2) - (clockFaceOutlineWidth / 2) }
    
    var body: some View {
        // Dial Background Border
        Circle()
        #if !os(watchOS)
            .strokeBorder(Color(uiColor: .systemGray3), lineWidth: clockFaceOutlineWidth )
        #elseif os(watchOS)
            .strokeBorder(Color(uiColor: .gray), lineWidth: clockFaceOutlineWidth)
        #endif
            .frame(width: self.width, height: self.width)
        // Clock Face Markings
        ForEach(Self.hours, id: \.self) { i in
            // Clock Nums
            let num = (i / 5) + 6
            Text("\(num > 12 ? num - 12 : num)")
                .font(.interFine)
                .rotationEffect(.degrees(Double(((num-12)) * -30) - 180))
                .offset(y: clockMarkOffset)
                .rotationEffect(Angle(degrees: Double(i) * 6))
        }
        ForEach(Self.quarterHours, id: \.self) { i in
            // Clock Tick Marks for 15 minute intervals between hours
            Circle()
                .fill(Color.primary)
                .frame(width: 2, height: 2)
                .offset(y: clockMarkOffset)
                .rotationEffect(.init(degrees: Double(i) * 6))
        }
    }
}

struct ClockFace_preview: PreviewProvider {
    static var previews: some View {
        Group {
            GeometryReader { geo in
                ClockFace(width: geo.size.width, clockFaceOutlineWidth: geo.size.width / 10)
            }
        }
    }
}
