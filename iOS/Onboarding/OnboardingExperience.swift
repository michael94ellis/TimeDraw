//
//  OnboardingExperience.swift
//  TimeDraw
//
//  Created by Michael Ellis on 9/11/22.
//

import SwiftUI
import ToastWindow

struct OnboardingExperience: View {
    var itemViewModel: ModifyCalendarItemViewModel
    var listViewModel: CalendarItemListViewModel
    
    @Environment(\.dismissAllToasts) private var dismissAllToasts
    @AppStorage(AppStorageKey.firstOpen) var isFirstAppOpen: Bool = true
    @State var currentPageIndex = 0
    
    func incrementOnboardingPage() {
        currentPageIndex += 1
        if currentPageIndex >= 6 {
            isFirstAppOpen = false
            dismissAllToasts()
            listViewModel.updateData()
        }
    }
    
    @ViewBuilder
    var demoScreenContent: some View {
        switch currentPageIndex {
        case 2:
            VStack {
                MainHeader()
                    .environmentObject(listViewModel)
                
                Text("Here's a swipeable weekly calendar to quickly see and navigate through the weeks")
                Spacer()
            }
        case 3:
            VStack {
                OnboardingDailyGoalTextField()
                Text("A space to write something about your day that doesn't fit as an Event or Reminder\n\nYou can hide this in settings")
                Spacer()
            }
        case 4:
            VStack {
                Spacer()
                TimeDrawClock(events: [], reminders: [])
                Text("The Analog Clock - visualize your events and reminders from any calendars")
                Spacer()
            }
        case 5:
            VStack {
                Spacer()
                Text("You can create events and reminders from TimeDraw as well")
                EventInput()
                    .environmentObject(itemViewModel)
            }
        default:
            EmptyView()
        }
    }
    
    var body: some View {
        ZStack {
            // Full-screen background that collects taps
            Color.systemBackground.ignoresSafeArea()
            
            VStack {
                switch currentPageIndex {
                case 0:
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Text("Hey There 👋\nWelcome to TimeDraw!\n\n\n\nTap anywhere")
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        Spacer()
                    }
                case 1:
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Text("Here's a quick intro to the app\n\n\n\n\n\nTap anywhere")
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        Spacer()
                    }
                default:
                    VStack(spacing: 0) {
                        Spacer()
                        demoScreenContent
                        Spacer()
                    }
                    .padding(24)
                }
            }
            .environmentObject(listViewModel)
            .padding(24)
            .contentShape(Rectangle())
            .onTapGesture { incrementOnboardingPage() }
        }
    }
}
