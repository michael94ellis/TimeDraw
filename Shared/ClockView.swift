//
//  ClockView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/9/22.
//

import SwiftUI

struct Time {
    var sec: Int
    var min: Int
    var hour: Int
}

struct TimeDrawClock: View {

    @State var currentTime = Time(sec: 0, min: 0, hour: 0)
    @State var timer = Timer.publish(every: 1, on: .current, in: .default).autoconnect()
    var width: CGFloat = 100
    
    func setCurrentTime()  {
        let calender = Calendar.current
        let sec = calender.component(.second, from: Date())
        let min = calender.component(.minute, from: Date())
        let hour = calender.component(.hour, from: Date())
        self.currentTime = Time(sec: sec, min: min, hour: hour)
    }
    
    @ViewBuilder var clockHands: some View {
        // DARKGRAY
        // Hours
        RoundedRectangle(cornerRadius: 24)
            .fill(Color.darkGray)
            .frame(width: 6, height: self.width * 0.5)
            .offset(y: -(self.width * 0.5) / 2)
            .rotationEffect(.init(degrees: Double(currentTime.hour + currentTime.min / 60) * 30))
        Circle()
            .fill(Color.darkGray)
            .frame(width: 16, height: 16)
        // Minutes
        RoundedRectangle(cornerRadius: 24)
            .fill(Color.darkGray)
            .frame(width: 4, height: self.width * 0.8)
            .offset(y: -(self.width * 0.8) / 3)
            .rotationEffect(.init(degrees: Double(currentTime.min) * 6))
        // RED1
        Circle()
            .fill(Color.red1)
            .frame(width: 10, height: 10)
        // Seconds
        RoundedRectangle(cornerRadius: 24)
            .fill(Color.red1)
            .frame(width: 2, height: self.width * 0.8)
            .offset(y: -(self.width * 0.8) / 2)
            .rotationEffect(.init(degrees: Double(currentTime.sec) * 6))
        // Shows the extended hand on the other side of the circle
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
                        .offset(y: self.width)
                        .rotationEffect(.init(degrees: Double(i) * 6))
                }
                self.clockHands
                ForEach(EventListViewModel.shared.events ,id: \.self) { event in
                    PartialCircleBorder(start: event.startDate, end: event.endDate, radius: self.width)
                        .foregroundColor(Color(cgColor: event.calendar.cgColor))
                    PartialCircleBorder(start: event.startDate, end: event.endDate, radius: self.width)
                        .foregroundColor(Color(cgColor: event.calendar.cgColor))
                }
                ForEach(EventListViewModel.shared.reminders ,id: \.self) { reminder in
                    PartialCircleBorder(startComponents: reminder.startDateComponents, endComponents: reminder.dueDateComponents, radius: self.width / 2)
                        .foregroundColor(Color(reminder.calendar.cgColor))
                }
            }
            .frame(width: self.width, height: self.width)
        }
        .frame(width: self.width * 2.5, height: self.width * 2.5)
        .onAppear(perform: {
            let calender = Calendar.current
            let sec = calender.component(.second, from: Date())
            let min = calender.component(.minute, from: Date())
            let hour = calender.component(.hour, from: Date())
            withAnimation(Animation.linear(duration: 0.01)) {
                self.currentTime = Time(sec: sec, min: min, hour: hour)
            }
        })
        .onReceive(self.timer) { _ in
            withAnimation(Animation.linear(duration: 0.01)) {
                self.setCurrentTime()
            }
        }
    }
}

struct PartialCircleBorder: Shape {
    
    enum EventType {
        case morning
        case evening
        case both
    }
    
    // Minute is 0.5 Degrees
    // Hour is 30 Degrees
    let start: Date?
    let end: Date?
    let startComponents: DateComponents?
    let endComponents: DateComponents?
    let radius: Double
    var startDegrees: Double = 0.0
    var endDegrees: Double = 0.0
    let type: EventType
    
    func getAngle(for date: Date? = nil, with components: DateComponents? = nil) -> Double {
        if let date = date {
            let hour = date.get(.hour)
            let trueHour = hour > 12 ? hour - 12 : hour
            return Double(trueHour * 30) + Double(date.get(.minute)) * 0.5
        } else if let hour = components?.hour,
                  let min = components?.minute {
            let trueHour = hour > 12 ? hour - 12 : hour
            return Double(trueHour) * 30.0 + Double(min) * 0.5
        } else {
            return 0.0
        }
    }
    
    init(start: Date, end: Date, radius: Double) {
        self.start = start
        self.end = end
        self.startComponents = nil
        self.endComponents = nil
        self.radius = radius
        if start.get(.hour) <= 12 {
            if end.get(.hour) >= 12 {
                self.type = .both
            } else {
                self.type = .morning
            }
        } else {
            self.type = .evening
        }
        self.startDegrees = self.getAngle(for: start)
        self.endDegrees = self.getAngle(for: end)
    }
    init(startComponents: DateComponents?, endComponents: DateComponents?, radius: Double) {
        self.startComponents = startComponents ?? DateComponents()
        self.endComponents = endComponents ?? DateComponents()
        self.start = nil
        self.end = nil
        self.radius = radius
        if startComponents?.hour ?? 0 <= 12 {
            if endComponents?.hour ?? 0 >= 12 {
                self.type = .both
            } else {
                self.type = .morning
            }
        } else {
            self.type = .evening
        }
        self.startDegrees = self.getAngle(with: startComponents)
        self.endDegrees = self.getAngle(with: endComponents)
    }
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        switch self.type {
        case .morning:
            p.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: self.radius * 0.8, startAngle: .degrees(self.startDegrees - 90), endAngle: .degrees(self.endDegrees - 90), clockwise: false)
        case.evening:
            p.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: self.radius * 1.2, startAngle: .degrees(self.startDegrees - 90), endAngle: .degrees(self.endDegrees - 90), clockwise: false)
        case .both:
            if self.startDegrees < 1 {
                p.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: self.radius * 0.8, startAngle: .degrees(self.startDegrees - 90), endAngle: .degrees(90), clockwise: false)
                p.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: self.radius * 0.8, startAngle: .degrees(90), endAngle: .degrees(self.startDegrees - 90), clockwise: false)
            } else {
                p.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: self.radius * 0.8, startAngle: .degrees(self.startDegrees - 90), endAngle: .degrees(-90), clockwise: false)
            }
            p.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: self.radius * 1.2, startAngle: .degrees(-90), endAngle: .degrees(self.endDegrees - 90), clockwise: false)
        }

        return p.strokedPath(.init(lineWidth: 16, lineCap: .round, lineJoin: .round))
    }
}
