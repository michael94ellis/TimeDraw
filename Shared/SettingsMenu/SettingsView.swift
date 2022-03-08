//
//  SettingsView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/6/22.
//

import SwiftUI

struct SettingsView: View {

    @Binding var showSettingsPopover: Bool
    @AppStorage("isDailyGoalEnabled") var isDailyGoalEnabled: Bool = true
    
    public init(display: Binding<Bool>) {
        self._showSettingsPopover = display
    }
    
    let vineetURL = "https://www.vineetk.com/"
    let michaelURL = "https://www.michaelrobertellis.com/"
    let byaruhofURL = "https://github.com/byaruhaf"
    
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
    
    var body: some View {
        NavigationView {
            VStack {
                Toggle("Enable Daily Goal Text Area", isOn: self.$isDailyGoalEnabled)
                    .padding(.horizontal)
                Spacer()
                Divider()
                
                self.link(for: self.vineetURL, title: "Design: Vineet Kapil")
                self.link(for: self.michaelURL, title: "iOS: Michael Robert Ellis")
                self.link(for: self.byaruhofURL, title: "iOS: Franklin Byaruhof")
                Button(action: { }, label: {
                    Spacer()
                    Image("smile.face")
                        .resizable()
                        .frame(width: 22, height: 22)
                    Text("Not Finished")
                        .frame(height: 48)
                    Spacer()
                }).buttonStyle(.plain)
                    .frame(height: 48)
                    .background(RoundedRectangle(cornerRadius: 34)
                                    .fill(Color(uiColor: .systemGray6)))
                    .padding(.horizontal, 20)
                Spacer()
                Spacer()
                Text("Version:\(Bundle.main.releaseVersionNumber) (\(Bundle.main.buildVersionNumber))")
                    .font(.interFine)
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
