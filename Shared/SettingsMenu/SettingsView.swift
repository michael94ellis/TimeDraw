//
//  SettingsView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/6/22.
//

import SwiftUI
import EventKit

class AppSettings: ObservableObject {
    @AppStorage("isDailyGoalEnabled") var isDailyGoalEnabled: Bool = true
    @AppStorage("isTimeDrawClockEnabled") var isTimeDrawClockEnabled: Bool = true
    @AppStorage("showItemRecurrenceType") var showItemRecurrenceType: ItemRecurrenceType = .all
    @AppStorage("showCalendarItemType") var showCalendarItemType: CalendarItemType = .scheduled
    @AppStorage("showListIcons") var showListIcons: Bool = true
    @AppStorage("showCalendarPickerButton") var showCalendarPickerButton: Bool = true
    @AppStorage("userSelectedCalendars") var userSelectedCalendars: Data?
    @AppStorage("currentSelectedCalendar") var currentSelectedCalendar: Data?
    
    // ---
    @AppStorage("showRecurringItems") var showRecurringItems: Bool = true
//    @AppStorage("showLocation") var showLocation: Bool = false
    @AppStorage("showNotes") var showNotes: Bool = false
    static let shared = AppSettings()
    
    private init() { }
    
    var allCalendars: [EKCalendar] = []
    
    @discardableResult
    func fetchAllCalendars() -> [EKCalendar] {
        var calendars = EventKitManager.shared.eventStore.calendars(for: .event)
        calendars.append(contentsOf: EventKitManager.shared.eventStore.calendars(for: .reminder))
        self.allCalendars = calendars
        return self.allCalendars
    }
}

struct SettingsView: View {
    
    public init(display: Binding<Bool>) {
        self._showSettingsPopover = display
    }
    
    @ObservedObject var appSettings: AppSettings = .shared
    
    @Binding var showSettingsPopover: Bool
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
            Text("Send Feedback!")
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
    
    @ViewBuilder var toggles: some View {
        VStack {
            Toggle("Enable Daily Goal Text Area", isOn: self.appSettings.$isDailyGoalEnabled)
                .padding(.horizontal)
            Toggle("Enable Time Draw Clock", isOn: self.appSettings.$isTimeDrawClockEnabled)
                .padding(.horizontal)
            Toggle("Show Recurrence", isOn: self.appSettings.$showRecurringItems)
                .padding(.horizontal)
            Toggle("Show Notes", isOn: self.appSettings.$showNotes)
                .padding(.horizontal)
            Toggle("Show Calendar Picker", isOn: self.appSettings.$showCalendarPickerButton)
                .padding(.horizontal)
            Toggle("Show List Icons", isOn: self.appSettings.$showListIcons)
                .padding(.horizontal)
                .onChange(of: self.appSettings.showListIcons, perform: { newValue in
                    EventListViewModel.shared.updateData()
                })
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    VStack {
                        self.toggles
                        CalendarSelectionButton()
                        Text("Show:")
                        Picker("", selection: self.appSettings.$showCalendarItemType) {
                            ForEach(CalendarItemType.allCases ,id: \.self) { item in
                                Text(item.displayName)
                            }
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: self.appSettings.showCalendarItemType, perform: { _ in
                            EventListViewModel.shared.updateData()
                        })
                        Picker("", selection: self.appSettings.$showItemRecurrenceType) {
                            ForEach(ItemRecurrenceType.allCases ,id: \.self) { item in
                                Text(item.displayName)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.top, 6)
                        .onChange(of: self.appSettings.showItemRecurrenceType, perform: { _ in
                            EventListViewModel.shared.updateData()
                        })
                    }
                    .padding()
                    Spacer()
                    Divider()
                    self.buttons
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

enum CalendarItemType: Int, CaseIterable {
    case scheduled = 0
    case unscheduled = 1
    case all = 2
    
    var displayName: String {
        switch(self) {
        case .scheduled: return "Scheduled"
        case .unscheduled: return "Unscheduled"
        case .all: return "All"
        }
    }
}
enum ItemRecurrenceType: Int, CaseIterable {
    case recurring = 0
    case nonRecurring = 1
    case all = 2
    
    var displayName: String {
        switch(self) {
        case .recurring: return "Recurring"
        case .nonRecurring: return "Non Recurring"
        case .all: return "All"
        }
    }
}
