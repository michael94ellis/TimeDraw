//
//  UserDefaults+AppGroup.swift
//  AppCore
//

import Foundation

public extension UserDefaults {
    /// Shared suite for the iOS app and widget extension.
    static let appGroupSuiteName = "group.com.michaelrobertellis.TimeDraw"

    static var appGroup: UserDefaults {
        UserDefaults(suiteName: appGroupSuiteName) ?? .standard
    }
}

public enum TimeDrawWidgetKind {
    public static let clock = "TimeDrawWidget"
}
