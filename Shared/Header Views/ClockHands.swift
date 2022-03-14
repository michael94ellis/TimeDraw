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
    
    var body: some View {
        // DARKGRAY
        // Hours
        RoundedRectangle(cornerRadius: 24)
            .fill(Color.darkGray)
            .frame(width: 6, height: self.width * 0.5)
            .offset(y: -(self.width * 0.5) / 2)
            .rotationEffect(.init(degrees: Double(currentTime.hour + currentTime.min / 60) * 30))
        Circle()
            .fill(Color.darkGray)
            .frame(width: self.width * 0.16, height: self.width * 0.16)
        // Minutes
        RoundedRectangle(cornerRadius: 24)
            .fill(Color.darkGray)
            .frame(width: 4, height: self.width * 0.8)
            .offset(y: -(self.width * 0.8) / 3)
            .rotationEffect(.init(degrees: Double(currentTime.min) * 6))
        // RED1
        Circle()
            .fill(Color.red1)
            .frame(width: self.width * 0.1, height: self.width * 0.1)
        // Seconds
        RoundedRectangle(cornerRadius: 24)
            .fill(Color.red1)
            .frame(width: 2, height: self.width * 0.8)
            .offset(y: -(self.width * 0.8) / 2)
            .rotationEffect(.init(degrees: Double(currentTime.sec) * 6))
        // Shows the extended hand on the other side of the circle
        RoundedRectangle(cornerRadius: 24)
            .fill(Color.red1)
            .frame(width: 2, height: self.width * 0.1)
            .offset(y: 10)
            .rotationEffect(.init(degrees: Double(currentTime.sec) * 6))
    }
}
