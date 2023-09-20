//
//  ClockView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/9/22.
//

import SwiftUI
import EventKit

struct Time {
    var sec: Int
    var min: Int
    var hour: Int
}

struct TimeDrawClock: View {
    
    @State var currentTime = Time(sec: 0, min: 0, hour: 0)
    @State var timer = Timer.publish(every: 1, on: .current, in: .default).autoconnect()
    var width: CGFloat
    @EnvironmentObject var itemList: CalendarItemListViewModel
    @EnvironmentObject var modifyItemViewModel: ModifyCalendarItemViewModel
    
    func setCurrentTime()  {
        let calender = Calendar.current
        let sec = calender.component(.second, from: Date())
        let min = calender.component(.minute, from: Date())
        let hour = calender.component(.hour, from: Date())
        self.currentTime = Time(sec: sec, min: min, hour: hour)
    }
        
    @ViewBuilder var timeCircles: some View {
        ForEach(self.itemList.events ,id: \.self) { event in
            if event.calendar == nil {
                EmptyView()
            } else if event.isAllDay {
                ClockEventLine(start: 0, end: 360, radius: self.width * 1.1, width: 2)
                    .foregroundColor(Color(cgColor: event.calendar.cgColor))
                    .gesture(TapGesture().onEnded({ value in
                        self.modifyItemViewModel.open(event: event)
                    }))
            } else {
                ClockEventLine(start: event.startDate, end: event.endDate, radius: self.width / 2, width: self.width / 24)
                    .foregroundColor(Color(cgColor: event.calendar.cgColor))
                    .gesture(TapGesture().onEnded({ value in
                        self.modifyItemViewModel.open(event: event)
                    }))
            }
        }
        ForEach(self.itemList.reminders ,id: \.self) { reminder in
            if let startDateComponents = reminder.startDateComponents, let dueDateComponents = reminder.dueDateComponents {
                ClockEventLine(startComponents: startDateComponents, endComponents: dueDateComponents, radius: self.width, width: 4)
                    .if((reminder.calendar != nil && reminder.calendar.cgColor != nil), transform: {
                        $0.foregroundColor(Color(reminder.calendar.cgColor))
                    })
                        .gesture(TapGesture().onEnded({ value in
                            self.modifyItemViewModel.open(reminder: reminder)
                        }))
            }
        }
    }
    
    var body: some View {
        VStack {
                ZStack {
                    // Event Lines
                    self.timeCircles
                    ClockFace(width: width, clockFaceOutlineWidth: width / 12)
                    // Moving Clock Parts
                    ClockHands(currentTime: self.$currentTime,
                               width: width)
            }
        }
        .frame(width: self.width, height: self.width)
        .onAppear(perform: {
            let calender = Calendar.current
            let currentDateTime = Date()
            let sec = calender.component(.second, from: currentDateTime)
            let min = calender.component(.minute, from: currentDateTime)
            let hour = calender.component(.hour, from: currentDateTime)
            withAnimation(Animation.linear(duration: 0.01)) {
                self.currentTime = Time(sec: sec, min: min, hour: hour)
                self.itemList.updateData()
            }
        })
        .onReceive(self.timer) { _ in
            withAnimation(Animation.linear(duration: 0.01)) {
                self.setCurrentTime()
            }
        }
    }
}

struct TimeDrawClock_preview: PreviewProvider {
    
    @ObservedObject private static var listViewModel: CalendarItemListViewModel = .shared
    @StateObject private static var itemViewModel: ModifyCalendarItemViewModel = ModifyCalendarItemViewModel()
    
    static var previews: some View {
        HStack {
            Spacer()
            GeometryReader { geo in
                TimeDrawClock(width: geo.size.width)
            }
            Spacer()
        }
        .environmentObject(Self.itemViewModel)
        .environmentObject(Self.listViewModel)
    }
}
