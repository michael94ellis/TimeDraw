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
    let byaruhofURL = "https://www.byaruhof.com/"
    
    var body: some View {
        NavigationView {
            VStack {
                Toggle("Enable Daily Goal Text Area", isOn: self.$isDailyGoalEnabled)
                    .padding(.horizontal)
                Spacer()
                Divider()
                
                Link(destination: URL(string: self.vineetURL)!) {
                    Spacer()
                    Text("Design: Vineet Kapil")
                    Spacer()
                }
                    .padding()
                    .frame(height: 48)
                    .background(RoundedRectangle(cornerRadius: 34)
                                    .fill(Color(uiColor: .systemGray6)))
                    .padding(.horizontal, 20)
                
                Link(destination: URL(string: self.michaelURL)!) {
                    Spacer()
                    Text("iOS Development: Michael Robert Ellis")
                    Spacer()
                }
                    .padding()
                    .frame(height: 48)
                    .background(RoundedRectangle(cornerRadius: 34)
                                    .fill(Color(uiColor: .systemGray6)))
                    .padding(.horizontal, 20)
                
                Link(destination: URL(string: self.byaruhofURL)!) {
                    Spacer()
                    Text("iOS Development: Franklin Byaruhof")
                    Spacer()
                }
                    .padding()
                    .frame(height: 48)
                    .background(RoundedRectangle(cornerRadius: 34)
                                    .fill(Color(uiColor: .systemGray6)))
                    .padding(.horizontal, 20)
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
