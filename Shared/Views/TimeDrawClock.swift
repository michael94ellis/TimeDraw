//
//  ClockView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/9/22.
//

import ClockFace
import EventKit
import SwiftUI

struct TimeDrawClock: View {
    
    @State var currentTime = Time(sec: 0, min: 0, hour: 0)
    @State var timer = Timer.publish(every: 1, on: .current, in: .default).autoconnect()
    var events: [EKEvent]
    var reminders: [EKReminder]
    
//    @Environment(\.openCalendarItem) var open
    
    func setCurrentTime()  {
        let timeZone = TimeZone.autoupdatingCurrent
        let components = Calendar.current.dateComponents(in: timeZone, from: .now)
        
        guard let hour = components.hour,
              let minute = components.minute,
              let second = components.second else { return }
        
        self.currentTime = Time(sec: second, min: minute, hour: hour)
    }

    @ViewBuilder
    private func eventLayers(clockSize: CGFloat) -> some View {
        let baseRadius = clockSize / 2
        let drawableItems = ClockDrawableItem.from(events: events, reminders: reminders)
        let layout = ClockEventLayoutEngine.layout(items: drawableItems, clockWidth: clockSize)

        ZStack {
            ForEach(layout.arcSegments) { segment in
                ClockEventLine(
                    arcRing: segment.ring,
                    startDegrees: segment.startDegrees,
                    endDegrees: segment.endDegrees,
                    radius: baseRadius,
                    width: Double(segment.lineWidth),
                    radiusOffset: segment.radiusOffset
                )
                .stroke(
                    segment.color,
                    style: StrokeStyle(
                        lineWidth: segment.lineWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
            }

            ForEach(layout.crossoverSegments) { segment in
                ClockCrossoverBend(
                    startDegrees: segment.startDegrees,
                    endDegrees: segment.endDegrees,
                    radius: baseRadius,
                    width: Double(segment.lineWidth),
                    radiusOffset: segment.radiusOffset
                )
                .stroke(
                    segment.color,
                    style: StrokeStyle(
                        lineWidth: segment.lineWidth,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
            }

            let allDayRadius = clockSize * 0.55
            let allDayLineWidth: CGFloat = 2
            let allDaySegments = ClockAllDayLayoutEngine.layout(
                events: ClockDrawableItem.allDayEvents(from: events)
            )
            ForEach((0..<allDaySegments.count), id: \.self) { index in
                ClockAllDayEventLine(
                    startDegrees: allDaySegments[index].startDegrees,
                    endDegrees: allDaySegments[index].endDegrees,
                    radius: (allDayRadius + (CGFloat(index + 1) * 3))
                )
                .stroke(
                    allDaySegments[index].color,
                    style: StrokeStyle(
                        lineWidth: allDayLineWidth,
                        lineCap: .round,
                        dash: [6, 4],
                        dashPhase: allDaySegments[index].dashPhase
                    )
                )
            }
        }
        .allowsHitTesting(false)
    }
    
    var body: some View {
        ZStack {
            ClockFace()
                .overlay {
                    GeometryReader { geo in
                        let size = min(geo.size.width, geo.size.height)
                        eventLayers(clockSize: size)
                            .frame(width: size, height: size)
                    }
                }
            ClockHands(currentTime: $currentTime)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .onAppear {
            let calendar = Calendar.current
            let currentDateTime = Date()
            let sec = calendar.component(.second, from: currentDateTime)
            let min = calendar.component(.minute, from: currentDateTime)
            let hour = calendar.component(.hour, from: currentDateTime)
            withAnimation(.linear(duration: 0.75)) {
                self.currentTime = Time(sec: sec, min: min, hour: hour)
            }
        }
        .onReceive(self.timer) { _ in
            withAnimation(.linear(duration: 0.01)) {
                self.setCurrentTime()
            }
        }
    }
}

#Preview("Phone") {
    struct TimeDrawClock_Previews: View {
        var body: some View {
            let mockEvents = [
                EKEvent.mock(startHour: 8, endHour: 10, color: .red),
                EKEvent.mock(startHour: 9, endHour: 10, color: .green),
                EKEvent.mock(startHour: 11, endHour: 13, color: .blue),
                EKEvent.mock(startHour: 11, endHour: 13, color: .cyan),
                EKEvent.mock(startHour: 14, endHour: 15, color: .orange),
                EKEvent.mock(startHour: 14, endHour: 16, color: .purple)
            ]
            let mockReminders = [
                EKReminder.mock(startHour: 10, endHour: nil, color: .yellow),
                EKReminder.mock(startHour: nil, endHour: 14, color: .magenta)
            ]
            
            #if os(iOS)
            let modifyViewModel = ModifyCalendarItemViewModel()
            
            return List {
                TimeDrawClock(events: mockEvents, reminders: mockReminders)
                    .padding(.horizontal, 16)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init())
                    .environmentObject(modifyViewModel)
                ForEach(0..<20, id: \.self) { i in
                    Text("Row \(i)")
                }
            }
            #else
                
            return List {
                TimeDrawClock(events: mockEvents, reminders: mockReminders)
                    .padding(.horizontal, 16)
                    .listRowInsets(.init())
                ForEach(0..<20, id: \.self) { i in
                    Text("Row \(i)")
                }
            }
            #endif
        }
    }
    
    return TimeDrawClock_Previews()
}

#Preview("Watch") {
    struct TimeDrawClock_Previews: View {
        var body: some View {
            let mockEvents = [
                EKEvent.mock(startHour: 8, endHour: 10, color: .red),
                EKEvent.mock(startHour: 9, endHour: 10, color: .green),
                EKEvent.mock(startHour: 11, endHour: 13, color: .blue),
                EKEvent.mock(startHour: 17, endHour: 24, color: .orange)
            ]
            let mockReminders = [
                EKReminder.mock(startHour: nil, endHour: nil, color: .yellow),
                EKReminder.mock(startHour: 1, endHour: nil, color: .purple)
            ]
            
            #if os(iOS)
            let modifyViewModel = ModifyCalendarItemViewModel()
            
            return VStack(spacing: 0) {
                Spacer()
                TimeDrawClock(events: mockEvents, reminders: mockReminders)
                Spacer()
            }
            .environmentObject(modifyViewModel)
            #else
            return VStack(spacing: 0) {
                Spacer()
                TimeDrawClock(events: mockEvents, reminders: mockReminders)
                Spacer()
            }
            #endif
        }
    }
    
    return TimeDrawClock_Previews()
}
