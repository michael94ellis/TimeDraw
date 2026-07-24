//
//  LayoutMetrics.swift
//  DesignToken
//

import SwiftUI

/// Form-aware layout tokens for chrome that should grow on pad (and later watch).
public struct LayoutMetrics: Sendable {
    public let form: DesignForm
    public let weekDayCellWidth: CGFloat
    public let weekDayLabelHeight: CGFloat
    public let weekDayCellVerticalPadding: CGFloat
    public let weekDayCellHorizontalPadding: CGFloat
    public let weekStripSpacing: CGFloat
    public let weekStripBottomPadding: CGFloat
    public let headerNavHorizontalPadding: CGFloat
    public let monthDayHitSize: CGFloat
    public let monthDayHitPadding: CGFloat
    public let monthColumnHeight: CGFloat
    public let expandedCalendarHorizontalPadding: CGFloat
    public let expandedCalendarTopPadding: CGFloat
    public let weekDaySelectionRadius: CGFloat
    public let calendarDayRadius: CGFloat
    public let daySelectionAnimationDuration: Double
    /// Outer horizontal padding around the clock in the main list.
    public let clockHorizontalPadding: CGFloat
    /// Outer vertical padding around the clock in the main list.
    public let clockVerticalPadding: CGFloat
    /// Inset between the clock view bounds and the face, leaving room for all-day rings.
    public let clockDrawingInset: CGFloat
    /// Horizontal edge inset for event/reminder list rows.
    public let listContentHorizontalPadding: CGFloat
    /// Vertical inset for event/reminder list rows.
    public let listContentVerticalPadding: CGFloat

    /// Shared column width for week strip and month grid.
    public var monthColumnWidth: CGFloat { weekDayCellWidth }

    public var listContentRowInsets: EdgeInsets {
        EdgeInsets(
            top: listContentVerticalPadding,
            leading: listContentHorizontalPadding,
            bottom: listContentVerticalPadding,
            trailing: listContentHorizontalPadding
        )
    }

    public static let phone = LayoutMetrics(
        form: .phone,
        weekDayCellWidth: 45,
        weekDayLabelHeight: 30,
        weekDayCellVerticalPadding: 8,
        weekDayCellHorizontalPadding: 1,
        weekStripSpacing: 4,
        weekStripBottomPadding: 6,
        headerNavHorizontalPadding: 16,
        monthDayHitSize: 36,
        monthDayHitPadding: 10,
        monthColumnHeight: 30,
        expandedCalendarHorizontalPadding: 25,
        expandedCalendarTopPadding: 8,
        weekDaySelectionRadius: 10,
        calendarDayRadius: 8,
        daySelectionAnimationDuration: 0.25,
        clockHorizontalPadding: 16,
        clockVerticalPadding: 20,
        clockDrawingInset: 12,
        listContentHorizontalPadding: 8,
        listContentVerticalPadding: 4
    )

    public static let pad = LayoutMetrics(
        form: .pad,
        weekDayCellWidth: 64,
        weekDayLabelHeight: 36,
        weekDayCellVerticalPadding: 12,
        weekDayCellHorizontalPadding: 2,
        weekStripSpacing: 8,
        weekStripBottomPadding: 10,
        headerNavHorizontalPadding: 24,
        monthDayHitSize: 44,
        monthDayHitPadding: 12,
        monthColumnHeight: 36,
        expandedCalendarHorizontalPadding: 32,
        expandedCalendarTopPadding: 12,
        weekDaySelectionRadius: 12,
        calendarDayRadius: 10,
        daySelectionAnimationDuration: 0.25,
        clockHorizontalPadding: 48,
        clockVerticalPadding: 24,
        clockDrawingInset: 20,
        listContentHorizontalPadding: 16,
        listContentVerticalPadding: 4
    )

    public static func metrics(for form: DesignForm = .current) -> LayoutMetrics {
        switch form {
        case .phone, .watch: .phone
        case .pad: .pad
        }
    }
}

private enum LayoutMetricsKey: EnvironmentKey {
    static let defaultValue: LayoutMetrics = .metrics()
}

public extension EnvironmentValues {
    var layoutMetrics: LayoutMetrics {
        get { self[LayoutMetricsKey.self] }
        set { self[LayoutMetricsKey.self] = newValue }
    }
}

private struct AdaptiveLayoutMetricsModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.environment(\.layoutMetrics, LayoutMetrics.metrics(for: .current))
    }
}

public extension View {
    /// Resolves `layoutMetrics` from package-dictated `DesignForm.current`.
    func adaptiveLayoutMetrics() -> some View {
        modifier(AdaptiveLayoutMetricsModifier())
    }
}
