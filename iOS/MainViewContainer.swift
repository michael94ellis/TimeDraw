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
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
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
    
    @ViewBuilder var mainContent: some View {
        VStack(spacing: 0) {
            MainHeader()
                .overlay(Divider(), alignment: .bottom)
            if self.appSettings.isDailyGoalEnabled {
                DailyGoalTextField(isDailyGoalFocused: self.$isDailyGoalFocused)
                    .clipped()
            }
            MainScrollableContent()
                .environmentObject(self.itemViewModel)
        }
    }
    
    @ViewBuilder var mainContentContainer: some View {
        ZStack {
            mainContent
                .transition(.opacity)
                .overlay(self.blurOverlay)
            VStack {
                Spacer()
                EventInput()
            }
            .padding(.bottom, safeAreaInsets.bottom)
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
