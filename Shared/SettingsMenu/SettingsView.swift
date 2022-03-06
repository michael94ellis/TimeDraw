//
//  SettingsView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/6/22.
//

import SwiftUI

struct SettingsView: View {
    
    @Binding var showSettingsPopover: Bool
    
    public init(display: Binding<Bool>) {
        self._showSettingsPopover = display
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Button(action: { }, label: {
                    Spacer()
                    Image("smile.face")
                        .resizable()
                        .frame(width: 22, height: 22)
                    Text("Something")
                        .frame(height: 48)
                    Spacer()
                }).buttonStyle(.plain)
                    .frame(height: 48)
                    .background(RoundedRectangle(cornerRadius: 34)
                                    .fill(Color(uiColor: .systemGray6)))
                    .padding(.horizontal, 20)
                Spacer()
            }
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
