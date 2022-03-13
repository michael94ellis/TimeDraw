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
    var width: CGFloat = 120
    @ObservedObject var eventList: EventListViewModel = .shared
    
    func setCurrentTime()  {
        let calender = Calendar.current
        let sec = calender.component(.second, from: Date())
        let min = calender.component(.minute, from: Date())
        let hour = calender.component(.hour, from: Date())
        self.currentTime = Time(sec: sec, min: min, hour: hour)
    }
        
    @ViewBuilder var timeCircles: some View {
        ForEach(self.eventList.events ,id: \.self) { event in
            if event.isAllDay {
                PartialCircleBorder(start: 0, end: 360, radius: self.width * 1.1, width: 2)
                    .foregroundColor(Color(cgColor: event.calendar.cgColor))
            } else {
                PartialCircleBorder(start: event.startDate, end: event.endDate, radius: self.width, width: 16)
                    .foregroundColor(Color(cgColor: event.calendar.cgColor))
            }
        }
        ForEach(self.eventList.reminders ,id: \.self) { reminder in
            PartialCircleBorder(startComponents: reminder.startDateComponents, endComponents: reminder.dueDateComponents, radius: self.width / 2, width: 16)
                .foregroundColor(Color(reminder.calendar.cgColor))
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                // Dial
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
                            .frame(width: 3, height: 3)
                            .offset(y: self.width)
                            .rotationEffect(.init(degrees: Double(i) * 6))
                    }
                }
                // Moving Clock Parts
                ClockHands(currentTime: self.$currentTime, width: self.width)
                // Event Lines
                self.timeCircles
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
    let width: Double
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
    
    init(start: Double, end: Double, radius: Double, width: Double, type: EventType = .evening) {
        self.startDegrees = start
        self.endDegrees = end
        self.radius = radius
        self.width = width
        self.type = type
        self.start = nil
        self.end = nil
        self.startComponents = nil
        self.endComponents = nil
    }
    
    init(start: Date, end: Date, radius: Double, width: Double) {
        self.start = start
        self.end = end
        self.startComponents = nil
        self.endComponents = nil
        self.radius = radius
        self.width = width
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
    init(startComponents: DateComponents?, endComponents: DateComponents?, radius: Double, width: Double) {
        self.startComponents = startComponents ?? DateComponents()
        self.endComponents = endComponents ?? DateComponents()
        self.start = nil
        self.end = nil
        self.radius = radius
        self.width = width
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
        let lineDashes: [CGFloat] = (self.start == nil && self.startComponents == nil) ? [10, 5] : []
        return p.strokedPath(.init(lineWidth: self.width, lineCap: .round, lineJoin: .round, dash: lineDashes))
    }
}
