//
//  TimeDrawApp.swift
//  Shared
//
//  Created by Michael Ellis on 1/2/22.
//

import SwiftUI
import EventKit

@main
struct TimeDrawApp: App {
    
    init() {
        UIFont.overrideInitialize()
        if AppSettings.shared.userSelectedCalendars == nil || AppSettings.shared.userSelectedCalendars.loadCalendarIds().isEmpty {
            let allCalendars = AppSettings.shared.fetchAllCalendars()
            AppSettings.shared.userSelectedCalendars = allCalendars.compactMap({ $0.calendarIdentifier }).archiveCalendars()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainViewContainer()
                .font(.interRegular)
        }
    }
}
