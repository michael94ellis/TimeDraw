//
//  ClackHands.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/13/22.
//

import SwiftUI

struct ClockHands: View {
    
    @Binding var currentTime: Time
    let width: CGFloat
    let secondsOffset: CGFloat
    let hoursOffset: CGFloat
    let cornerRounding: CGFloat = 24
    
    init (currentTime: Binding<Time>, width: CGFloat) {
        self._currentTime = currentTime
        self.width = width
        self.secondsOffset = width * 0.48
        self.hoursOffset = width * 0.38
    }
    
    var body: some View {
        // DARKGRAY
        // Hours
        RoundedRectangle(cornerRadius: cornerRounding)
            .fill(Color.darkGray)
            .frame(width: 6, height: hoursOffset)
            .offset(y: -(hoursOffset) / 2)
            .rotationEffect(.init(degrees: Double(currentTime.hour + currentTime.min / 60) * 30))
        // Grey Center Circle
        let greyCircleSize = width * 0.09
        Circle()
            .fill(Color.darkGray)
            .frame(width: greyCircleSize, height: greyCircleSize)
        // Minutes
        RoundedRectangle(cornerRadius: cornerRounding)
            .fill(Color.darkGray)
            .frame(width: 4, height: width * 0.48)
            .offset(y: -(width * 0.7) / 3)
            .rotationEffect(.init(degrees: Double(currentTime.min) * 6))
        // Red Center Circle
        let redCircleSize = width * 0.05
        Circle()
            .fill(Color.red1)
            .frame(width: redCircleSize, height: redCircleSize)
        // Seconds
        RoundedRectangle(cornerRadius: cornerRounding)
            .fill(Color.red1)
            .frame(width: 2, height: secondsOffset)
            .offset(y: -(secondsOffset) / 2)
            .rotationEffect(.init(degrees: Double(currentTime.sec) * 6))
        // Shows the extended hand on the other side of the circle
        RoundedRectangle(cornerRadius: cornerRounding)
            .fill(Color.red1)
            .frame(width: 2, height: width * 0.2)
            .offset(y: 10)
            .rotationEffect(.init(degrees: Double(currentTime.sec) * 6))
    }
}
