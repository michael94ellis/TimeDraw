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
    @EnvironmentObject var itemList: CalendarItemListViewModel
    @EnvironmentObject var modifyItemViewModel: ModifyCalendarItemViewModel
    
    func setCurrentTime()  {
        let timeZone = TimeZone.autoupdatingCurrent
        let components = Calendar.current.dateComponents(in: timeZone, from: .now)
        
        guard let hour = components.hour,
              let minute = components.minute,
              let second = components.second else { return }
        
        self.currentTime = Time(sec: second, min: minute, hour: hour)
    }
    
    @ViewBuilder
    func timeCircles() -> some View {
        GeometryReader { geo in
            let width = min(geo.size.width, geo.size.height)
            ForEach(itemList.events, id: \.self) { event in
                let radius = event.isAllDay ? width * 1.1 : width / 2
                let lineWidth = event.isAllDay ? 2 : width / 24
                ClockEventLine(start: event.startDate,
                               end: event.endDate,
                               radius: radius,
                               width: lineWidth)
                    .foregroundColor(Color(cgColor: event.calendar?.cgColor ?? UIColor.clear.cgColor))
                    .gesture(TapGesture().onEnded {
                        modifyItemViewModel.open(event: event)
                    })
            }
            ForEach(itemList.reminders, id: \.self) { reminder in
                if let startDateComponents = reminder.startDateComponents {
                    if let dueDateComponents = reminder.dueDateComponents {
                        ClockEventLine(startComponents: startDateComponents, endComponents: dueDateComponents, radius: width / 2, width: 4)
                            .foregroundColor(reminder.calendar?.cgColor.map { Color($0) } ?? Color.clear)
                            .gesture(TapGesture().onEnded({ value in
                                self.modifyItemViewModel.open(reminder: reminder)
                            }))
                    } else {
                        ClockEventLine(startComponents: startDateComponents,
                                       endComponents: startDateComponents,
                                       radius: width / 2,
                                       width: 4)
                        .foregroundColor(reminder.calendar?.cgColor.map { Color($0) } ?? Color.clear)
                        .gesture(TapGesture().onEnded {
                            modifyItemViewModel.open(reminder: reminder)
                        })
                    }
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            ClockHands(currentTime: $currentTime)
            timeCircles()
            ClockFace()
        }
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
            let viewModel = CalendarItemListViewModel()
            viewModel.events = [
                EKEvent.mock(startHour: 8, endHour: 10, color: .red),
                EKEvent.mock(startHour: 11, endHour: 13, color: .blue),
                EKEvent.mock(startHour: 17, endHour: 24, color: .orange)
            ]
            viewModel.reminders = [
                .mock(startHour: nil, endHour: nil, color: .yellow),
                .mock(startHour: 1, endHour: nil, color: .purple),
                .mock(startHour: 1, endHour: 2, color: .cyan)
            ]
            
            let modifyViewModel = ModifyCalendarItemViewModel()
            
            return GeometryReader { geo in
                List {
                    HStack {
                        Spacer()
                        TimeDrawClock()
                        Spacer()
                    }
                    Rectangle()
                        .fill(Color.black)
                        .overlay(content: {
                            Text("Hey there this is an event")
                                .foregroundStyle(.white)
                        })
                }
            }
            .environmentObject(viewModel)
            .environmentObject(modifyViewModel)
        }
    }
    
    return TimeDrawClock_Previews()
}

#Preview("Watch") {
    struct TimeDrawClock_Previews: View {
        var body: some View {
            let viewModel = CalendarItemListViewModel()
            viewModel.events = [
                EKEvent.mock(startHour: 8,
                             endHour: 10,
                             color: .red),
                EKEvent.mock(startHour: 11,
                             endHour: 13,
                             color: .blue),
                EKEvent.mock(startHour: 17,
                             endHour: 24,
                             color: .orange)
            ]
            viewModel.reminders = [
                .mock(startHour: nil, endHour: nil, color: .yellow),
                .mock(startHour: 1, endHour: nil, color: .purple),
                .mock(startHour: 22, endHour: 23, color: .cyan)
            ]
            
            let modifyViewModel = ModifyCalendarItemViewModel()
            
            return VStack(spacing: 0) {
                Spacer()
                TimeDrawClock()
                Spacer()
            }
            .environmentObject(viewModel)
            .environmentObject(modifyViewModel)
        }
    }
    
    return TimeDrawClock_Previews()
}
