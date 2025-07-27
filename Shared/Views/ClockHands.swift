//
//  ClackHands.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/13/22.
//

import SwiftUI

struct ClockHands: View {
    
    @Binding var currentTime: Time
    let cornerRounding: CGFloat = 24

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let secondsOffset = size * 0.48
            let hoursOffset = size * 0.35

            ZStack {
                // Hours hand
                let hourFraction = Double(currentTime.min) / 60.0
                let hourAngle = Double(currentTime.hour) * 30.0 + hourFraction * 30.0

                RoundedRectangle(cornerRadius: cornerRounding)
                    .fill(Color.darkGray)
                    .frame(width: 8, height: hoursOffset)
                    .offset(y: -hoursOffset / 2)
                    .rotationEffect(.degrees(hourAngle))

                // Minutes hand
                RoundedRectangle(cornerRadius: cornerRounding)
                    .fill(Color.darkGray)
                    .frame(width: 4, height: size * 0.48)
                    .offset(y: -(size * 0.7) / 3)
                    .rotationEffect(.degrees(Double(currentTime.min) * 6))

                // Center circles
                Circle()
                    .fill(Color.darkGray)
                    .frame(width: size * 0.09, height: size * 0.09)
                Circle()
                    .fill(Color.red1)
                    .frame(width: size * 0.05, height: size * 0.05)

                // Seconds hand
                RoundedRectangle(cornerRadius: cornerRounding)
                    .fill(Color.red1)
                    .frame(width: 2, height: secondsOffset)
                    .offset(y: -secondsOffset / 2)
                    .rotationEffect(.degrees(Double(currentTime.sec) * 6))

                RoundedRectangle(cornerRadius: cornerRounding)
                    .fill(Color.red1)
                    .frame(width: 2, height: size * 0.2)
                    .offset(y: 10)
                    .rotationEffect(.degrees(Double(currentTime.sec) * 6))
            }
            .frame(width: size, height: size)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
