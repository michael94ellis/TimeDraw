//
//  SettingsView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/6/22.
//

import AppCore
import AppStoreReviewRequest
import DesignToken
import EventKit
import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    
    public init(navPath: Binding<NavigationPath>) {
        self._navPath = navPath
    }
    
    @EnvironmentObject var appSettings: AppSettings
    @Binding var navPath: NavigationPath
    
    var body: some View {
        Form {
            SettingsControlsView()
            
            Section {
                Button("Open Device Settings App") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.app(.body))
            } header: {
                Text("Device Settings")
                    .font(.app(.listTitle))
            }
            
#if DEBUG
            Section {
                DebugSeedTestDataButton()
            } header: {
                Text("Debug")
                    .font(.app(.listTitle))
            }
#endif
            
            Section {
                NavigationLink {
                    CalendlyInlineWidgetView()
                } label: {
                    Text("Contact")
                        .font(.app(.body))
                }
                Button("Show Onboarding Info") {
                    navPath.append(MainViewContainer.NavLocation.onboarding)
                }
                .font(.app(.body))
                Button("Share Feedback!") {
                    ReviewRequestManager().requestReviewIfAppropriate(for: .standard)
                }
                .font(.app(.body))
                HStack {
                    Text("Version")
                        .font(.app(.body))
                    Spacer()
                    Text("\(Bundle.main.releaseVersionNumber) (\(Bundle.main.buildVersionNumber))")
                        .font(.app(.fine))
                        .foregroundStyle(Colors.secondaryText)
                }
            } header: {
                Text("About")
                    .font(.app(.listTitle))
            }
        }
        .font(.app(.body))
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}
