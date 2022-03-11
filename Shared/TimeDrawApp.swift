//
//  TimeDrawApp.swift
//  Shared
//
//  Created by Michael Ellis on 1/2/22.
//

import SwiftUI
import Firebase

@main
struct TimeDrawApp: App {
    
    let persistenceController = CoreDataManager.shared
    
    init() {
        FirebaseApp.configure()
        EventKitManager.configureWithAppName("TimeDraw")
        UIFont.overrideInitialize()
        if AppSettings.shared.userSelectedCalendars == nil || AppSettings.shared.userSelectedCalendars.loadCalendarIds().isEmpty {
            var calendars = EventKitManager.shared.eventStore.calendars(for: .event)
            calendars.append(contentsOf: EventKitManager.shared.eventStore.calendars(for: .reminder))
            AppSettings.shared.userSelectedCalendars = calendars.compactMap({ $0.calendarIdentifier }).archiveCalendars()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .font(.interRegular)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
