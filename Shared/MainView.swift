//
//  MainView.swift
//  Shared
//
//  Created by Michael Ellis on 1/2/22.
//

import SwiftUI
import CoreData
import EventKit

struct MainView: View {
        
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DailyGoal.date, ascending: true)],
        animation: .default)
    private var dailyGoals: FetchedResults<DailyGoal>
    
    private let date = Date()
    
    @State private var hideClockView = false
    @State private var displayAddEventModal = false
    @State private var isShowingAddEventBackgroundBlur = false
    @State var isShowingDatePicker: Bool = false
    @FocusState private var isDailyGoalFocused: Bool
    @FocusState var isNewEventFocused: Bool
    @ObservedObject private var eventManager: EventManager = .shared
    
    init() {
        Task {
            EventManager.shared.events = try await EventManager.shared.fetchEventsForToday()
            try await EventManager.shared.fetchReminders()
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                MainHeader(for: self.date)
                DailyGoalTextField(isDailyGoalFocused: self.$isDailyGoalFocused)
                Spacer()
                // Clock View todo in v2
                Divider()
                EventsAndRemindersMainList()
            }
            .if(self.isShowingAddEventBackgroundBlur) { view in
                view.background(Color.lightGray)
                    .edgesIgnoringSafeArea(.bottom)
                    .blur(radius: 0)
                    .blur(radius: 2)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            self.isShowingAddEventBackgroundBlur = false
                            self.isShowingDatePicker = false
                            self.isNewEventFocused = false
                        }
                    }
            }
            VStack {
                Spacer()
                AddEventFloatingInputView(isShowingBackgroundBlur: self.$isShowingAddEventBackgroundBlur, isShowingDatePicker: self.$isShowingDatePicker, isNewEventFocused: self.$isNewEventFocused)
                    .onChange(of: self.isNewEventFocused, perform: { isFocused in
                        if isFocused { self.isShowingAddEventBackgroundBlur = true }
                    })
            }
            .frame(alignment: .bottom)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    self.isShowingAddEventBackgroundBlur = false
                    self.isShowingDatePicker = false
                    self.isNewEventFocused = false
                }
            }
        }
    }
}
