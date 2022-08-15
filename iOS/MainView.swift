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
    
    var body: some View {
        ZStack {
            VStack {
                MainHeader()
                if self.appSettings.isDailyGoalEnabled {
                    DailyGoalTextField(isDailyGoalFocused: self.$isDailyGoalFocused)
                        .clipped()
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
        .sheet(isPresented: self.$isFirstAppOpen, onDismiss: {
            self.isFirstAppOpen = false
        }, content: {
            Text("Welcome")
            Image(systemName: "calendar")
            Text("This is some intro text")
            Text(" 1. Lorem Ipsum")
            Text(" 2. Dolor Amet")
            Button("Done", action: { self.isFirstAppOpen = false })
        })
    }
}
