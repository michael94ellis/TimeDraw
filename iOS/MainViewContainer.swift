//
//  MainView.swift
//  Shared
//
//  Created by Michael Ellis on 1/2/22.
//

import CoreData
import EventInput
import AppCore
import DailyGoalTextfield
import EventKit
import EventUIComponents
import SwiftUI

struct MainViewContainer: View {
    
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var itemViewModel: ModifyCalendarItemViewModel
    @EnvironmentObject private var listViewModel: CalendarItemListViewModel
    
    /// The secondary textfield that can be edited
    @FocusState private var isDailyGoalFocused: Bool

    @ViewBuilder var blurOverlay: some View {
        if self.itemViewModel.isAddEventTextFieldFocused {
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                Color.black.opacity(0.15)
            }
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    self.itemViewModel.isAddEventTextFieldFocused = false
                }
            }
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
    
    var body: some View {
        ZStack {

            if appSettings.isFirstAppOpen {
                OnboardingExperience(itemViewModel: itemViewModel, listViewModel: listViewModel)
                    .environmentObject(appSettings)
                    .zIndex(1)
            } else {
                
                mainContent
                    .transition(.opacity)
                    .overlay(self.blurOverlay)
                VStack {
                    Spacer()
                    EventInput()
                        .environmentObject(appSettings)
                }
            }
        }
    }
}
