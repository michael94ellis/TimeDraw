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
    
    @AppStorage("first_open") var isFirstAppOpen = true
    /// Simple state toggle for displaying the main Clock Control
    @State var showClockView: Bool = true
    /// The secondary textfield that can be edited
    @FocusState private var isDailyGoalFocused: Bool
    
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
    
    @ViewBuilder var mainContentView: some View {
        VStack {
            MainHeader()
            if self.appSettings.isDailyGoalEnabled {
                DailyGoalTextField(isDailyGoalFocused: self.$isDailyGoalFocused)
                    .clipped()
            }
            Spacer()
            if self.appSettings.isTimeDrawClockEnabled {
                if self.showClockView {
                    TimeDrawClock(showClockView: self.$showClockView, width: 120)
                }
                Button(action: {
                    withAnimation {
                        self.showClockView.toggle()
                    }
                }) {
                    Image(systemName: self.showClockView ? "chevron.down" : "chevron.up")
                }
                .frame(width: 40, height: 35)
                .contentShape(Rectangle())
            }
            Divider()
            EventsAndRemindersMainList()
                .environmentObject(self.itemViewModel)
        }
        .transition(.opacity)
        .ignoresSafeArea(.keyboard)
        .edgesIgnoringSafeArea(.bottom)
        .overlay(self.blurOverlay)
        VStack {
            EventInput(isBackgroundBlurred: self.$itemViewModel.isAddEventTextFieldFocused)
                .padding(.bottom, 16)
        }
    }
    
    @ViewBuilder var mainContentContainer: some View {
        Group {
            if self.itemViewModel.isAddEventTextFieldFocused {
                ZStack {
                    mainContentView
                }
            } else {
                VStack {
                    mainContentView
                }
            }
        }
    }
    
    var body: some View {
        Group {
            if isFirstAppOpen {
                OnboardingExperience(isFirstAppOpen: self.$isFirstAppOpen)
            } else {
                mainContentContainer
            }
        }
        .environmentObject(self.itemViewModel)
        .environmentObject(self.listViewModel)
        .environmentObject(self.appSettings)
    }
}
