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
    
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var itemViewModel: ModifyCalendarItemViewModel
    
    /// The secondary textfield that can be edited
    @FocusState private var isDailyGoalFocused: Bool
    
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
                    .environmentObject(appSettings)
            }
            .padding(.bottom, safeAreaInsets.bottom)
        }
    }
    
    var body: some View {
        VStack {
            if appSettings.isFirstAppOpen {
                OnboardingExperience()
            } else {
                mainContentContainer
            }
        }
    }
}
