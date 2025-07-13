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
    
    @StateObject private var appSettings: AppSettings = .init()
    @StateObject private var listViewModel: CalendarItemListViewModel = .init()
    @StateObject private var itemViewModel: ModifyCalendarItemViewModel = .init()
    
    init() {
        UIFont.overrideInitialize()
    }
    
    var body: some Scene {
        WindowGroup {
            MainViewContainer()
                .environmentObject(itemViewModel)
                .environmentObject(listViewModel)
                .environmentObject(appSettings)
        }
    }
}
