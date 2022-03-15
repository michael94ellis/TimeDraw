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
    
    private let date = Date()
    @State var showClockView: Bool = true
    @FocusState private var isDailyGoalFocused: Bool
    @State var swipeDirection: SwipeDirection = .left
    @ObservedObject private var appSettings: AppSettings = .shared
    @ObservedObject private var listViewModel: CalendarItemListViewModel = .shared
    @StateObject private var itemViewModel: ModifyCalendarItemViewModel = ModifyCalendarItemViewModel()
    
    @ViewBuilder var blurOverlay: some View {
        if self.itemViewModel.isAddEventTextFieldFocused {
            Color.black.opacity(0.6)
                .blur(radius: 1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .blur(radius: 1)
                .contentShape(Rectangle())
                .gesture(TapGesture().onEnded({
                    withAnimation {
                        self.itemViewModel.isAddEventTextFieldFocused = false
                    }
                }))
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    var body: some View {
        ZStack {
            // Primary Display
            VStack {
                MainHeader()
                if self.appSettings.isDailyGoalEnabled {
                    DailyGoalTextField(isDailyGoalFocused: self.$isDailyGoalFocused)
                }
                Spacer()
                if self.appSettings.isTimeDrawClockEnabled {
                    if self.showClockView {
                        TimeDrawClock(showClockView: self.$showClockView)
                    }
                    Button(action: {
                        withAnimation {
                            self.showClockView.toggle()
                        }
                    }) {
                        Image(systemName: self.showClockView ? "chevron.up" : "chevron.down")
                    }
                    .frame(height: 35)
                }
                // Clock View todo in v2
                Divider()
                EventsAndRemindersMainList()
                    .environmentObject(self.itemViewModel)
            }
            .transition(.opacity)
            .ignoresSafeArea(.keyboard)
            .edgesIgnoringSafeArea(.bottom)
            // Blurred Background
            .overlay(self.blurOverlay)
            VStack {
                Spacer()
                FloatingEventInput(isBackgroundBlurred: self.$itemViewModel.isAddEventTextFieldFocused)
                    .padding(.bottom, 16)
            }
        }
        .environmentObject(self.itemViewModel)
        .environmentObject(self.listViewModel)
        .environmentObject(self.appSettings)
    }
}
