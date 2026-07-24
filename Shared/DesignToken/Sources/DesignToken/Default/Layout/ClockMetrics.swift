//
//  ClockMetrics.swift
//  DesignToken
//

import CoreFoundation

/// Drawing constants for the clock face and event rings.
public enum ClockMetrics {
    /// All-day event arc radius as a fraction of the clock's content size.
    /// Values above `0.5` sit outside the face and need `LayoutMetrics.clockDrawingInset`.
    public static let allDayRadiusFactor: CGFloat = 0.55
    /// Extra radius added per stacked all-day ring.
    public static let allDayRingSpacing: CGFloat = 3
    public static let allDayLineWidth: CGFloat = 2
    public static let allDayDash: [CGFloat] = [6, 4]
}
