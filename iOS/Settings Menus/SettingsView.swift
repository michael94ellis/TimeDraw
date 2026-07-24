//
//  SettingsView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/6/22.
//

import SwiftUI
import AppCore
import EventKit
import StoreKit
import UIKit
import AppStoreReviewRequest

struct SettingsView: View {

    public init(navPath: Binding<NavigationPath>) {
        self._navPath = navPath
    }

    @EnvironmentObject var appSettings: AppSettings
    @Binding var navPath: NavigationPath

    var body: some View {
//        NavigationStack {
            Form {
                SettingsControlsView()

                Section("Device Settings") {
                    Button("Open Device Settings App") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }

                #if DEBUG
                Section("Debug") {
                    DebugSeedTestDataButton()
                }
                #endif

                Section("About") {
                    NavigationLink {
                        CalendlyInlineWidgetView()
                    } label: {
                        Text("Contact")
                    }
                    Button("Show Onboarding Info") {
                        navPath.append(MainViewContainer.NavLocation.onboarding)
                    }
                    Button("Share Feedback!") {
                        ReviewRequestManager().requestReviewIfAppropriate(for: .standard)
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("\(Bundle.main.releaseVersionNumber) (\(Bundle.main.buildVersionNumber))")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
//        }
    }
}
