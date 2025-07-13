//
//  MainHeader.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/6/22.
//

import SwiftUI


struct MainHeader: View {
    
    @State private var showSettingsPopover = false
    // TODO: Add a full month calendar feature somewhere
    @EnvironmentObject var itemList: CalendarItemListViewModel
    @State var swipeDirection: SwipeDirection = .left
    
    func transitionDirection(direction: SwipeDirection) -> AnyTransition {
        let slideIn: Edge = direction == .right ? .trailing : .leading
        return .asymmetric(insertion: .move(edge: slideIn), removal: .opacity)
    }
    
    func switchTransition(direction: SwipeDirection) -> AnyTransition {
        return .asymmetric(insertion: .move(edge: .top), removal: .move(edge: .top))
    }
    
    private let weekdayFormatter = DateFormatter(format: "EEE")
    private let monthYearFormatter = DateFormatter(format: "LLLL YYYY")
    
    func weekDayHeader(for date: Date) -> some View {
        let today = Calendar.current.isDateInToday(date)
        let display = Calendar.current.isDate(date, inSameDayAs: self.itemList.displayDate)
        return VStack {
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
    }
    
    func handleGesture(value: SwipeDirection) {
        self.swipeDirection = value
        let type: Calendar.Component = .day
        let amount = 7
        switch value {
        case .left:
            self.itemList.displayDate = Calendar.current.date(byAdding: type, value: -amount, to: self.itemList.displayDate) ?? Date()
        case .right:
            self.itemList.displayDate = Calendar.current.date(byAdding: type, value: amount, to: self.itemList.displayDate) ?? Date()
        default:
            break
        }
    }
    
    enum SettingsScreen {
        case main
        case calendars
    }
    
    var headerNav: some View {
        HStack {
            Text(self.monthYearFormatter.string(from: self.itemList.displayDate))
                .font(.interExtraBoldTitle)
                .fontWeight(.semibold)
                .foregroundColor(Color.red1)
            Spacer()
            Button(action: { self.showSettingsPopover.toggle() }) {
                Image(systemName: "ellipsis")
                    .frame(width: 40, height: 30)
            }
            .buttonStyle(.plain)
            .frame(width: 55, height: 55)
            .onTapGesture {
                self.showSettingsPopover.toggle()
            }
            .contentShape(Rectangle())
            .sheet(isPresented: self.$showSettingsPopover, content: {
                SettingsView(display: $showSettingsPopover)
            })
        }
        .padding(.horizontal)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            self.headerNav
            HStack(spacing: 4) {
                ForEach(Calendar.current.daysWithSameWeekOfYear(as: self.itemList.displayDate), id: \.self) { date in
                    Button(action: {
                        self.itemList.displayDate = date
                    }, label: {
                        if Calendar.current.isDate(date, inSameDayAs: self.itemList.displayDate) {
                            self.weekDayHeader(for: date)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.2)))
                        } else {
                            self.weekDayHeader(for: date)
                        }
                    })
                    .buttonStyle(.plain)
                }
                .transition(self.transitionDirection(direction: self.swipeDirection))
            }
            .padding(.bottom, 6)
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
