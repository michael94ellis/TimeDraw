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

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
