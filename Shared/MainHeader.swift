//
//  MainHeader.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/6/22.
//

import SwiftUI


struct MainHeader: View {
    
    @State private var showSettingsPopover = false
    @State private var showCalendarSelectionPopover = false
    /// True means only show 1 week
    @AppStorage("compactHeader") private var showCompactCalendar = true
    @ObservedObject private var eventList: EventListViewModel = .shared
    @State var swipeDirection: SwipeDirection = .left
    
    func transitionDirection(direction: SwipeDirection) -> AnyTransition {
        let slideIn: Edge = direction == .right ? .trailing : .leading
        return .asymmetric(insertion: .move(edge: slideIn), removal: .opacity)
    }
    
    func switchTransition(direction: SwipeDirection) -> AnyTransition {
        let slideOut: Edge = self.showCompactCalendar ? .top : .top
        return .asymmetric(insertion: .move(edge: slideOut), removal: .move(edge: .top))
    }
    
    private let weekdayFormatter = DateFormatter()
    private let monthYearFormatter = DateFormatter()
    
    init() {
        self.weekdayFormatter.dateFormat = "EEE"
        self.monthYearFormatter.dateFormat = "LLLL YYYY"
    }
    
    func weekDayHeader(for date: Date) -> some View {
        Button(action: {
            self.eventList.displayDate = date
        }) {
            let today = Calendar.current.isDateInToday(date)
            let display = Calendar.current.isDate(date, inSameDayAs: self.eventList.displayDate)
            VStack {
                Text(self.weekdayFormatter.string(from: date))
                    .font(today || display ? .interSemiBold : .interLight)
                    .foregroundColor(Color(uiColor: .label))
                    .frame(height: 30)
                Text(date.get(.day).formatted())
                    .font(today ? .interBold : display ? .interSemiBold : .interRegular)
                    .foregroundColor(today ? Color.red1 : display ? Color(uiColor: .label) : Color.gray2)
            }
            .frame(width: 45)
            .padding(.vertical, 8)
            .padding(.horizontal, 1)
            .if(Calendar.current.isDate(date, inSameDayAs: self.eventList.displayDate)) { view in
                view.background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.2)))
            }
        }
        .buttonStyle(.plain)
    }
    
    func handleGesture(value: SwipeDirection) {
        self.swipeDirection = value
        let type: Calendar.Component = self.showCompactCalendar ? .day : .month
        let amount: Int = self.showCompactCalendar ? 7 : 1
        switch value {
        case .left:
            self.eventList.displayDate = Calendar.current.date(byAdding: type, value: -amount, to: self.eventList.displayDate) ?? Date()
        case .right:
            self.eventList.displayDate = Calendar.current.date(byAdding: type, value: amount, to: self.eventList.displayDate) ?? Date()
        default:
            self.showCompactCalendar.toggle()
        }
    }
    
    func toggleMonthButton(forward: Bool) -> some View {
        Button(action: {
            withAnimation {
                self.eventList.displayDate = Calendar.current.date(byAdding: .month, value: forward ? 1 : -1, to: self.eventList.displayDate) ?? Date()
            }
        }) {
            Image(systemName: forward ? "chevron.right" : "chevron.left")
                .foregroundColor(Color.red1)
        }
    }
    
    var headerNav: some View {
        HStack {
            Button(action: {
                withAnimation {
                    self.showCompactCalendar.toggle()
                }
            }) {
                Text(self.monthYearFormatter.string(from: self.eventList.displayDate))
                    .font(.interExtraBoldTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.red1)
            }
            if !self.showCompactCalendar {
                self.toggleMonthButton(forward: false)
                    .padding(.leading)
                self.toggleMonthButton(forward: true)
                    .padding(.horizontal)
            }
            Spacer()
            Menu(content: {
                Button("Settings", action: { self.showSettingsPopover.toggle() })
                Button("Select Calendars", action: { self.showCalendarSelectionPopover.toggle() })
            }, label: { Image(systemName: "ellipsis")
                .frame(width: 40, height: 30) })
                .fullScreenCover(isPresented: self.$showSettingsPopover, content: {
                    SettingsView(display: $showSettingsPopover)
                })
                .sheet(isPresented: self.$showCalendarSelectionPopover) {
                    CalendarSelection(showingCalendarSelection: self.$showCalendarSelectionPopover)
                }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if self.showCompactCalendar {
                self.headerNav
                HStack {
                    ForEach(Calendar.current.daysWithSameWeekOfYear(as: self.eventList.displayDate), id: \.self) { date in
                        self.weekDayHeader(for: date)
                    }
                    .transition(self.transitionDirection(direction: self.swipeDirection))
                }
            } else {
                self.headerNav
                CalendarDateSelection(date: self.$eventList.displayDate, showCompactCalendar: self.$showCompactCalendar)
                    .transition(self.switchTransition(direction: self.swipeDirection))
                    .padding(.top, 8)
                    .padding(.horizontal, 25)
            }
        }
        .transition(self.switchTransition(direction: self.swipeDirection))
        .gesture(DragGesture()
                    .onEnded { value in
            withAnimation {
                let direction = value.detectDirection()
                self.handleGesture(value: direction)
            }
        })
    }
}
