//
//  MultiDateSelectCalendar.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/8/22.
//

import DesignToken
import AppCore
import SwiftUI

/// A month-agnostic day-of-month picker (1...31) used to choose which days a
/// monthly/yearly recurrence should repeat on.
///
/// The grid is built with a `LazyVGrid` of flexible columns so it always fills
/// the width offered by its parent instead of forcing a fixed intrinsic width.
/// This keeps the surrounding `EventInput` panel from being stretched wider than
/// the screen padding intends.
struct CalendarMultiDateSelection: View {

    @Binding private var selectedDates: [Int]

    private let days = Array(1...31)
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    init(selectedDates: Binding<[Int]>) {
        self._selectedDates = selectedDates
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(days, id: \.self) { day in
                dayCell(day)
            }
        }
    }

    private func dayCell(_ day: Int) -> some View {
        let isSelected = selectedDates.contains(day)
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                toggle(day)
            }
        } label: {
            Text(String(day))
                .font(isSelected ? .app(.dayNumberToday) : .app(.dayNumber))
                .foregroundStyle(isSelected ? Colors.onAccentBackground : Colors.primaryText)
                .frame(maxWidth: .infinity, minHeight: 34)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.calendarDayRadius, style: .continuous)
                        .fill(isSelected ? Colors.action : Colors.recurrenceDayDefaultBackground)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Day \(day)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func toggle(_ day: Int) {
        if selectedDates.contains(day) {
            selectedDates.removeAll { $0 == day }
        } else {
            selectedDates.append(day)
        }
    }
}
