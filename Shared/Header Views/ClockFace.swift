//
//  ClockFace.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/16/22.
//

import SwiftUI

struct ClockFace: View {
    
    let width: CGFloat
    
    var body: some View {
        // Dial Background Border
        Circle()
            .strokeBorder(Color(uiColor: .systemGray3), lineWidth: 24)
            .frame(width: self.width * 2.2, height: self.width * 2.2)
        // Clock Face Markings
        ForEach(0..<60, id: \.self) { i in
            if i % 5 == 0 {
                // Clock Nums
                let num = (i / 5) + 6
                Text("\(num > 12 ? num - 12 : num)")
                    .font(.interFine)
                    .rotationEffect(.degrees(Double(((num-12)) * -30) - 180))
                    .offset(y: self.width)
                    .rotationEffect(Angle(degrees: Double(i) * 6))
            } else {
                // Clock Tick Marks for Minutes
                Circle()
                    .fill(Color.primary)
                    .frame(width: 2, height: 2)
                    .offset(y: self.width)
                    .rotationEffect(.init(degrees: Double(i) * 6))
            }
        }
    }
}
