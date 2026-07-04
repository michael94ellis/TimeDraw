//
//  ClockView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/9/22.
//

import SwiftUI
import EventKit

struct TimeDrawClock: View {
    
    @State var currentTime = Time(sec: 0, min: 0, hour: 0)
    @State var timer = Timer.publish(every: 1, on: .current, in: .default).autoconnect()
    var events: [EKEvent]
    var reminders: [EKReminder]
    
    @Environment(\.openCalendarItem) var open
    
    func setCurrentTime()  {
        let timeZone = TimeZone.autoupdatingCurrent
        let components = Calendar.current.dateComponents(in: timeZone, from: .now)
        
        guard let hour = components.hour,
              let minute = components.minute,
              let second = components.second else { return }
        
        self.currentTime = Time(sec: second, min: minute, hour: hour)
    }

    private func crossoverFill(for segment: ClockCrossoverSegment) -> some ShapeStyle {
        if segment.colors.count == 1, let color = segment.colors.first {
            return AnyShapeStyle(color)
        }
        return AnyShapeStyle(
            AngularGradient(
                gradient: Gradient(colors: segment.colors),
                center: .center,
                startAngle: .degrees(segment.startDegrees),
                endAngle: .degrees(segment.endDegrees)
            )
        )
    }

    @ViewBuilder
    private func eventLayers(clockSize: CGFloat) -> some View {
        let baseRadius = clockSize / 2
        let baseWidth = clockSize / 24
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
                    width: Double(baseWidth)
                )
                .fill(crossoverFill(for: segment))
            }
            let allDayEvents = ClockDrawableItem.allDayEvents(from: events)
            if !allDayEvents.isEmpty {
                ForEach(ClockDrawableItem.allDayEvents(from: events), id: \.self) { event in
                    let radius = clockSize * 0.75
                    ClockEventLine(start: event.startDate,
                                   end: event.endDate,
                                   radius: radius,
                                   width: 2)
                    .foregroundColor(Color(cgColor: event.calendar?.cgColor ?? UIColor.clear.cgColor))
                }
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
            
            #if !os(watchOS)
            let modifyViewModel = ModifyCalendarItemViewModel()
            #endif
            
            return List {
                #if !os(watchOS)
                TimeDrawClock(events: mockEvents, reminders: mockReminders)
                    .padding(.horizontal, 16)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init())
                #else
                TimeDrawClock(events: mockEvents, reminders: mockReminders)
                    .padding(.horizontal, 16)
                    .listRowInsets(.init())
                #endif
                ForEach(0..<20, id: \.self) { i in
                    Text("Row \(i)")
                }
                
                
            }
            #if !os(watchOS)
            .environmentObject(modifyViewModel)
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
            
            #if !os(watchOS)
            let modifyViewModel = ModifyCalendarItemViewModel()
            #endif
            
            return VStack(spacing: 0) {
                Spacer()
                TimeDrawClock(events: mockEvents, reminders: mockReminders)
                Spacer()
            }
            #if !os(watchOS)
            .environmentObject(modifyViewModel)
            #endif
        }
    }
    
    return TimeDrawClock_Previews()
}
