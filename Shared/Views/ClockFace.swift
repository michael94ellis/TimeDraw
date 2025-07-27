//
//  ClockFace.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/16/22.
//

import SwiftUI

struct ClockFace: View {
    
    @ViewBuilder
    func hands(markOffset: CGFloat) -> some View {
        let hours: [Int] = (0..<60).filter({ $0 % 5 == 0 })
        let quarterHours: [Double] = {
            var calculatedQuarterHourDegrees: [Double] = []
            hours.forEach({ calculatedQuarterHourDegrees.append(contentsOf: [Double($0) + 1, Double($0) + 2, Double($0) + 3, Double($0) + 4])})
            return calculatedQuarterHourDegrees
        }()
        // Hour numbers
        ForEach(hours, id: \.self) { i in
            let num = (i / 5) + 6
            Text("\(num > 12 ? num - 12 : num)")
                .rotationEffect(.degrees(Double((num - 12) * -30) - 180))
                .offset(y: markOffset)
                .rotationEffect(Angle(degrees: Double(i) * 6))
        }
        
        // Tick marks
        ForEach(quarterHours, id: \.self) { i in
            Circle()
                .fill(Color.primary)
                .frame(width: 2, height: 2)
                .offset(y: markOffset)
                .rotationEffect(.degrees(Double(i) * 6))
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let outlineWidth: CGFloat = size / 12
            let markOffset = (size / 2) - (outlineWidth / 2)

            ZStack {
                // Border Circle
                Circle()
                #if !os(watchOS)
                    .strokeBorder(Color(uiColor: .systemGray3), lineWidth: outlineWidth)
                #else
                    .strokeBorder(Color(uiColor: .gray), lineWidth: outlineWidth)
                #endif
                    .frame(width: size, height: size)

                hands(markOffset: markOffset)
            }
            .frame(width: size, height: size)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    Group {
        GeometryReader { geo in
            ClockFace()
        }
    }
}
