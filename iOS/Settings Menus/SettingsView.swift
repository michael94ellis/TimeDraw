//
//  SettingsView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/6/22.
//

import SwiftUI
import EventKit

struct SettingsView: View {
    
    public init(display: Binding<Bool>) {
        self._showSettingsPopover = display
    }
    
    @ObservedObject var appSettings: AppSettings = .shared
    
    @Binding var showSettingsPopover: Bool
    let vineetURL = "https://www.vineetk.com/"
    let michaelURL = "https://www.michaelrobertellis.com/"
    let ayushURL = "https://github.com/ac-dev01"
    let contactURL = "https://www.michaelrobertellis.com/contact"
    
    func link(for url: String, title: String) -> some View {
        Link(destination: URL(string: url)!) {
            Spacer()
            Text(title)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Spacer()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 34)
                        .fill(Color(uiColor: .systemGray6)))
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder var settingsFooter: some View {
        self.link(for: self.vineetURL, title: "Design: Vineet Kapil")
        self.link(for: self.michaelURL, title: "iOS: Michael Robert Ellis")
        self.link(for: self.ayushURL, title: "iOS: Ayush Chaurasia")
        Link(destination: URL(string: self.contactURL)!) {
            Spacer()
            Image("smile.face")
                .resizable()
                .frame(width: 22, height: 22)
            Text("Send Feedback!")
                .frame(height: 48)
            Spacer()
        }
        .background(RoundedRectangle(cornerRadius: 34)
                        .fill(Color(uiColor: .systemGray6)))
        .padding(.horizontal, 20)
        Spacer()
        Spacer()
        Text("Version:\(Bundle.main.releaseVersionNumber) (\(Bundle.main.buildVersionNumber))")
            .font(.interFine)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    SettingsControls()
                        .padding()
                    Spacer()
                    Divider()
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
