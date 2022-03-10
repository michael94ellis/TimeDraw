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
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .font(.interRegular)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
