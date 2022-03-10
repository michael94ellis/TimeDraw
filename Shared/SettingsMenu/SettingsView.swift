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
    @AppStorage("isTimeDrawClockEnabled") var isTimeDrawClockEnabled: Bool = true
    @AppStorage("showCalendarItemType") var showCalendarItemType: CalendarItemType = .events
    
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
    
    @ViewBuilder var buttons: some View {
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
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Toggle("Enable Daily Goal Text Area", isOn: self.$isDailyGoalEnabled)
                    .padding(.horizontal)
                Toggle("Enable Time Draw Clock", isOn: self.$isTimeDrawClockEnabled)
                    .padding(.horizontal)
                VStack {
                    Text("Show Only:")
                    Picker("", selection: self.$showCalendarItemType) {
                        ForEach(CalendarItemType.allCases ,id: \.self) { item in
                            Text(item.displayName)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding()
                Spacer()
                Divider()
                self.buttons
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

enum CalendarItemType: Int, CaseIterable {
    case events = 0
    case reminders = 1
    case all = 2
    
    var displayName: String {
        switch(self) {
        case .events: return "Events"
        case .reminders: return "Reminders"
        case .all: return "All"
        }
    }
}
