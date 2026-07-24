//
//  MainHeaderView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/6/22.
//

import SwiftUI
import AppCore
import DesignToken

struct MainHeaderView: View {
    
    enum SettingsScreen {
        case main
        case calendars
    }
    
    private let weekdayFormatter = DateFormatter(format: "EEE")
    private let monthYearFormatter = DateFormatter(format: "LLLL YYYY")
    
    @Namespace private var weekdaySelection
    // TODO: Add a full month calendar feature somewhere
    @EnvironmentObject var itemList: CalendarItemListViewModel
    @Environment(\.layoutMetrics) private var layoutMetrics
    @Binding var navPath: NavigationPath
    @State var swipeDirection: SwipeDirection = .left
    
    func transitionDirection(direction: SwipeDirection) -> AnyTransition {
        let slideIn: Edge = direction == .right ? .trailing : .leading
        return .asymmetric(insertion: .move(edge: slideIn), removal: .opacity)
    }
    
    func switchTransition(direction: SwipeDirection) -> AnyTransition {
        return .asymmetric(insertion: .move(edge: .top), removal: .move(edge: .top))
    }
    
    func weekDayHeader(for date: Date) -> some View {
        let today = Calendar.current.isDateInToday(date)
        let display = Calendar.current.isDate(date, inSameDayAs: self.itemList.displayDate)
        return VStack {
            Text(self.weekdayFormatter.string(from: date))
                .font(today || display ? .app(.weekdayEmphasized) : .app(.weekday))
                .foregroundColor(Colors.primaryText)
                .frame(height: layoutMetrics.weekDayLabelHeight)
                .animation(nil, value: itemList.displayDate)
            Text(date.get(.day).formatted())
                .font(
                    today ? .app(.dayNumberToday)
                        : display ? .app(.dayNumberSelected)
                        : .app(.dayNumber)
                )
                .foregroundColor(today ? Colors.today : display ? Colors.primaryText : Colors.mutedText)
                .animation(nil, value: itemList.displayDate)
        }
        .frame(width: layoutMetrics.weekDayCellWidth)
        .padding(.vertical, layoutMetrics.weekDayCellVerticalPadding)
        .padding(.horizontal, layoutMetrics.weekDayCellHorizontalPadding)
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
    
    var headerNav: some View {
        HStack {
            Text(self.monthYearFormatter.string(from: self.itemList.displayDate))
                .font(.app(.headerTitle))
                .foregroundColor(Colors.today)
            Spacer()
            Button {
                navPath.append(MainViewContainer.NavLocation.appSettings)
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.app(.iconMedium))
                    .foregroundStyle(Colors.primaryText)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, layoutMetrics.headerNavHorizontalPadding)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            self.headerNav
            HStack(spacing: layoutMetrics.weekStripSpacing) {
                ForEach(Calendar.current.daysWithSameWeekOfYear(as: self.itemList.displayDate), id: \.self) { date in
                    Button {
                        withAnimation(.easeInOut(duration: layoutMetrics.daySelectionAnimationDuration)) {
                            itemList.displayDate = date
                        }
                    } label: {
                        weekDayHeader(for: date)
                            .background {
                                if Calendar.current.isDate(date, inSameDayAs: itemList.displayDate) {
                                    RoundedRectangle(cornerRadius: layoutMetrics.weekDaySelectionRadius, style: .continuous)
                                        .fill(Colors.weekDaySelectionFill)
                                        .matchedGeometryEffect(id: "weekDaySelection", in: weekdaySelection)
                                }
                            }
                            .id("WeekDayHeader\(date)")
                    }
                    .buttonStyle(.plain)
                }
                .transition(self.transitionDirection(direction: self.swipeDirection))
            }
            .padding(.bottom, layoutMetrics.weekStripBottomPadding)
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
