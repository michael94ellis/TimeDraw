//
//  SettingsView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/6/22.
//

import SwiftUI
import EventKit

extension Array {
    func archiveCalendars() -> Data {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            return data
        } catch {
            fatalError("Can't encode data: \(error)")
        }
    }
}
extension Optional where Wrapped == Data {
    func loadCalendarIds() -> [String] {
        do {
            guard let data = self,
                  let array = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String] else {
                return []
            }
            return array
        } catch {
            fatalError("loadWStringArray - Can't encode data: \(error)")
        }
    }
}


class AppSettings: ObservableObject {
    @AppStorage("isDailyGoalEnabled") var isDailyGoalEnabled: Bool = true
    @AppStorage("isTimeDrawClockEnabled") var isTimeDrawClockEnabled: Bool = true
    @AppStorage("showItemRecurrenceType") var showItemRecurrenceType: ItemRecurrenceType = .all
    @AppStorage("showCalendarItemType") var showCalendarItemType: CalendarItemType = .scheduled
    @AppStorage("showListIcons") var showListIcons: Bool = true
    @AppStorage("showCalendarPickerButton") var showCalendarPickerButton: Bool = true
    @AppStorage("userSelectedCalendars") var userSelectedCalendars: Data?
    
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
    @State var showingCalendarSelection: Bool = false
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
            MultiPicker(self.appSettings.userSelectedCalendars.loadCalendarIds(),
                        selections: Binding<[String]>(get: {
                self.appSettings.userSelectedCalendars.loadCalendarIds()
            }, set: { newArray in
                self.appSettings.userSelectedCalendars = newArray.archiveCalendars()
            }))
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    VStack {
                        Button(action: {
                            self.showingCalendarSelection.toggle()
                            self.appSettings.fetchAllCalendars()
                        }) {
                            Spacer()
                            Text("Select Calendars")
                            Spacer()
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 34)
                                        .fill(Color(uiColor: .systemGray6)))
                        .padding(.horizontal, 20)
                        .sheet(isPresented: self.$showingCalendarSelection) {
                            let selectedIds = AppSettings.shared.userSelectedCalendars.loadCalendarIds()
                            HStack {
                                Spacer()
                                Text("Select Your Calendars")
                                    .font(Font.interTitle)
                                Spacer()
                            }
                            .padding(.top)
                            List {
                                ForEach(self.appSettings.allCalendars, id: \.self) { calendar in
                                    Button(action: {
                                        var newIds = self.appSettings.userSelectedCalendars.loadCalendarIds()
                                        if newIds.contains(where: { $0 == calendar.calendarIdentifier }) {
                                            newIds.removeAll(where: { $0 == calendar.calendarIdentifier })
                                            self.appSettings.userSelectedCalendars = newIds.archiveCalendars()
                                        } else {
                                            newIds.append(calendar.calendarIdentifier)
                                            self.appSettings.userSelectedCalendars = newIds.archiveCalendars()
                                        }
                                    }) {
                                        HStack {
                                            Circle().fill(Color(cgColor: calendar.cgColor)).frame(width: 20, height: 20)
                                            Text(calendar.title)
                                            Spacer()
                                            if selectedIds.contains(calendar.calendarIdentifier) {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        self.toggles
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
