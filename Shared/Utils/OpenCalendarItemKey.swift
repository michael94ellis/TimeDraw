//
//  OpenCalendarItemKey.swift
//  TimeDraw
//
//  Created by Michael Ellis on 7/27/25.
//

import SwiftUI
import EventKit

typealias OpenCalendarItemClosure = (EKCalendarItem) -> Void

private struct OpenCalendarItemKey: EnvironmentKey {
    static var defaultValue: OpenCalendarItemClosure = { _ in }
}

extension EnvironmentValues {
    var openCalendarItem: OpenCalendarItemClosure {
        get { self[OpenCalendarItemKey.self] }
        set { self[OpenCalendarItemKey.self] = newValue }
    }
}
