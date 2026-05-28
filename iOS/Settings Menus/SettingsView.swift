//
//  SettingsView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/6/22.
//

import SwiftUI
import EventKit
import StoreKit

struct SettingsView: View {

    public init(display: Binding<Bool>) {
        self._showSettingsPopover = display
    }

    @EnvironmentObject var appSettings: AppSettings
    @Binding var showSettingsPopover: Bool

    private let vineetURL = "https://www.vineetk.com/"
    private let michaelURL = "https://www.michaelrobertellis.com/"

    var body: some View {
        NavigationStack {
            Form {
                SettingsControls()

                Section("About") {
                    Link(destination: URL(string: michaelURL)!) {
                        Text("iOS: Michael Robert Ellis")
                    }
                    Link(destination: URL(string: vineetURL)!) {
                        Text("Design: Vineet Kapil")
                    }
                    NavigationLink {
                        CalendlyInlineWidgetView()
                    } label: {
                        Text("Contact")
                    }
                    Button("Show Onboarding Info") {
                        appSettings.isFirstAppOpen = true
                    }
                    Button("Share Feedback!") {
                        ReviewRequestManager.shared.requestReview()
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
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showSettingsPopover = false
                    }
                }
            }
        }
    }
}
