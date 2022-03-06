//
//  TimeDrawApp.swift
//  Shared
//
//  Created by Michael Ellis on 1/2/22.
//

import SwiftUI

@main
struct TimeDrawApp: App {
    
    let persistenceController = CoreDataManager.shared
    
    init() {
        EventKitManager.configureWithAppName("TimeDraw")
        UIFont.overrideInitialize()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .font(.interRegular)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
