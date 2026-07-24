//
//  MainView.swift
//  Shared
//
//  Created by Michael Ellis on 1/2/22.
//

import AppCore
import AppStoreReviewRequest
import CoreData
import DailyGoalTextfield

import EventInput
import EventKit
import EventUIComponents
import Onboarding
import SwiftUI

struct MainViewContainer: View {
    
    enum NavLocation: Hashable {
        case onboarding
        case appSettings
    }
    
    @State private var navPath: NavigationPath = .init()
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var itemViewModel: ModifyCalendarItemViewModel
    @EnvironmentObject private var listViewModel: CalendarItemListViewModel
    /// Observable user default
    @AppStorage(AppStorageKey.firstOpen) public var isFirstAppOpen = true
    
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
            MainHeaderView(navPath: $navPath)
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
        NavigationStack(path: $navPath) {
            ZStack {
                mainContent
                    .transition(.opacity)
                    .overlay(self.blurOverlay)
                VStack {
                    Spacer()
                    EventInput(eventCreationAction: {
                        ReviewRequestManager().requestReviewIfAppropriate(for: UserDefaults.standard)
                    })
                    .environmentObject(appSettings)
                }
            }
            .navigationDestination(for: NavLocation.self) { navLocation in
                switch navLocation {
                case .onboarding:
                    OnboardingExperience(
                        itemViewModel: itemViewModel,
                        listViewModel: listViewModel,
                        headerDemo: { MainHeaderView(navPath: $navPath) },
                        clockDemo: { TimeDrawClock(events: [], reminders: []) }
                    )
                        .environmentObject(appSettings)
                case .appSettings:
                    SettingsView(navPath: $navPath)
                }
            }
        }
    }
}
