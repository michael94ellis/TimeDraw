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
    
    @ObservedObject var appSettings: AppSettings = .init()
    
    @Binding var showSettingsPopover: Bool
    let vineetURL = "https://www.vineetk.com/"
    let michaelURL = "https://www.michaelrobertellis.com/"
    let contactURL = "https://www.michaelrobertellis.com/contact"
    
    func link(for url: String, title: String) -> some View {
        Link(destination: URL(string: url)!) {
            Text(title)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 18)
        }
        .padding(.vertical)
        .padding(.horizontal, 18)
        .background(RoundedRectangle(cornerRadius: 34)
                        .fill(Color(uiColor: .systemGray6)))
    }
    
    @ViewBuilder var settingsFooter: some View {
        
        Button("Show Onboarding Info") {
            appSettings.isFirstAppOpen = true
        }
        Button("Share Feedback!") {
            ReviewRequestManager.shared.requestReview()
        }
        Image("Clock")
            .resizable()
            .frame(width: 66, height: 66)
        Text("Team")
        link(for: self.vineetURL, title: "Design: Vineet Kapil")
        link(for: self.michaelURL, title: "iOS: Michael Robert Ellis")
        Spacer()
        Text("Version \(Bundle.main.releaseVersionNumber) (\(Bundle.main.buildVersionNumber))")
            .font(.interFine)
        Spacer()
        Spacer()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    SettingsControls()
                        .padding()
                    Spacer()
                    self.settingsFooter
                }
                .padding(.horizontal)
                .padding(.top, 22)
                .navigationTitle("Settings")
                .toolbar(content:  {
                    HStack {
                        Spacer()
                        Button("Done", action: { self.showSettingsPopover.toggle() })
                    }
                })
            }
        }
    }
}
