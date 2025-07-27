//
//  MainView.swift
//  Shared
//
//  Created by Michael Ellis on 1/2/22.
//

import CoreData
import EventKit
import SwiftUI
import ToastWindow

struct MainViewContainer: View {
    
    @Environment(\.toastManager) private var toastManager
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var itemViewModel: ModifyCalendarItemViewModel
    @EnvironmentObject private var listViewModel: CalendarItemListViewModel
    
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
    
    var body: some View {
        ZStack {
            mainContent
                .transition(.opacity)
                .overlay(self.blurOverlay)
            VStack {
                Spacer()
                EventInput()
                    .environmentObject(appSettings)
            }
        }
        .onAppear {
            showOnboardingIfAppropriate()
        }
        .onChange(of: appSettings.isFirstAppOpen) { _ in
            showOnboardingIfAppropriate()
        }
    }
    
    func showOnboardingIfAppropriate() {
        if appSettings.isFirstAppOpen {
            _ = toastManager.showToast(content: OnboardingExperience(itemViewModel: itemViewModel, listViewModel: listViewModel))
        }
    }
}
