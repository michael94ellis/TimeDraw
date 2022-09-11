//
//  ClockView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/9/22.
//

import SwiftUI
import Foundation

struct Time {
    var sec: Int
    var min: Int
    var hour: Int
}

struct TimeDrawClock: View {
    
    @Binding var showClockView: Bool
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
    
    func handleClockViewSwipe(for direction: SwipeDirection) {
        if [.down, .up].contains(direction) {
            withAnimation {
                self.showClockView.toggle()
            }
        }
        if [.left, .right].contains(direction) {
            withAnimation {
                self.itemList.displayDate = Calendar.current.date(byAdding: .day, value: direction == .right ? 1 : -1, to: self.itemList.displayDate) ?? Date()
            }
        }
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
                ClockEventLine(start: event.startDate, end: event.endDate, radius: self.width, width: 12)
                    .foregroundColor(Color(cgColor: event.calendar.cgColor))
                    .gesture(TapGesture().onEnded({ value in
                        self.modifyItemViewModel.open(event: event)
                    }))
            }
        }
        ForEach(self.itemList.reminders ,id: \.self) { reminder in
            ClockEventLine(startComponents: reminder.startDateComponents, endComponents: reminder.dueDateComponents, radius: self.width, width: 4)
                .foregroundColor(Color(reminder.calendar.cgColor))
                .gesture(TapGesture().onEnded({ value in
                    self.modifyItemViewModel.open(reminder: reminder)
                }))
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                // Event Lines
                self.timeCircles
                ClockFace(width: self.width)
                // Moving Clock Parts
                ClockHands(currentTime: self.$currentTime, width: self.width)
            }
            .frame(width: self.width, height: self.width)
        }
        .frame(width: self.width * 2.5, height: self.width * 2.5)
        .gesture(DragGesture().onEnded({ value in
            self.handleClockViewSwipe(for: value.detectDirection())
        }))
        .onAppear(perform: {
            let calender = Calendar.current
            let sec = calender.component(.second, from: Date())
            let min = calender.component(.minute, from: Date())
            let hour = calender.component(.hour, from: Date())
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
