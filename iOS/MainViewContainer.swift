//
//  MainView.swift
//  Shared
//
//  Created by Michael Ellis on 1/2/22.
//

import SwiftUI
import CoreData
import EventKit

struct MainViewContainer: View {
    
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
    }
    
    @ViewBuilder var mainContentContainer: some View {
        ZStack {
            mainContentView
                .ignoresSafeArea()
                .overlay(self.blurOverlay)
            VStack {
                Spacer()
                EventInput()
                    .padding(.bottom, UIDevice.current.bottomNotchHeight * 1.15)
            }
            .padding(.bottom, UIDevice.current.bottomNotchHeight)
        }
    }
    
    var body: some View {
        VStack {
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
