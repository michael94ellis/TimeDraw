//
//  ClockView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/9/22.
//

import SwiftUI

struct TimeDrawClock: View {
    
    struct Time {
        var sec: Int
        var min: Int
        var hour: Int
    }
    
    @State var currentTime = Time(sec: 0, min: 0, hour: 0)
    @State var timer = Timer.publish(every: 1, on: .current, in: .default).autoconnect()
    var width = UIScreen.main.bounds.width
    
    func setCurrentTime()  {
        let calender = Calendar.current
        let sec = calender.component(.second, from: Date())
        let min = calender.component(.minute, from: Date())
        let hour = calender.component(.hour, from: Date())
        self.currentTime = Time(sec: sec, min: min, hour: hour)
    }
    
    @ViewBuilder var clockHands: some View {
        //Hours
        RoundedRectangle(cornerRadius: 24)
            .fill(Color.darkGray)
            .frame(width: 6, height: (width - 240) / 2)
            .offset(y: -(width - 240) / 4)
            .rotationEffect(.init(degrees: Double(currentTime.hour + currentTime.min / 60) * 30))
        Circle()
            .fill(Color.darkGray)
            .frame(width: 16, height: 16)
        //Minutes
        RoundedRectangle(cornerRadius: 24)
            .fill(Color.darkGray)
            .frame(width: 4, height: (width - 150) / 2)
            .offset(y: -(width - 200) / 4)
            .rotationEffect(.init(degrees: Double(currentTime.min) * 6))
        Circle()
            .fill(Color.red1)
            .frame(width: 10, height: 10)
        //Seconds
        RoundedRectangle(cornerRadius: 24)
            .fill(Color.red1)
            .frame(width: 2, height: (width - 180) / 2)
            .offset(y: -(width - 180) / 4)
            .rotationEffect(.init(degrees: Double(currentTime.sec) * 6))
        RoundedRectangle(cornerRadius: 24)
            .fill(Color.red1)
            .frame(width: 2, height: 10)
            .offset(y: 10)
            .rotationEffect(.init(degrees: Double(currentTime.sec) * 6))
    }
        
    var body: some View {
        VStack {
            ZStack {// Dial
                Circle()
                    .fill(Color(uiColor: .systemBackground))
                // Seconds And Min dots...
                ForEach(0..<60, id: \.self){ i in
                    Rectangle()
                        .fill(Color.primary)
                        .frame(width: 2, height: (i % 5) == 0 ? 15 : 5)// 60/12 = 5
                        .offset(y: (width - 110) / 2)
                        .rotationEffect(.init(degrees: Double(i) * 6))
                }
                self.clockHands
            }
            .frame(width: width - 80, height: width - 80)
            Spacer()
        }
        .onAppear(perform: {
            let calender = Calendar.current
            let sec = calender.component(.second, from: Date())
            let min = calender.component(.minute, from: Date())
            let hour = calender.component(.hour, from: Date())
            withAnimation(Animation.linear(duration: 0.01)){
                self.currentTime = Time(sec: sec, min: min, hour: hour)
            }
        })
        .onReceive(self.timer) { _ in
            withAnimation(Animation.linear(duration: 0.01)){
                self.setCurrentTime()
            }
        }
    }
}

struct PartialCircleBorder : Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()

        p.addArc(center: CGPoint(x: 100, y:100), radius: 50, startAngle: .degrees(34), endAngle: .degrees(73), clockwise: true)

        return p.strokedPath(.init(lineWidth: 3, dash: [5, 3], dashPhase: 10))
    }
}
