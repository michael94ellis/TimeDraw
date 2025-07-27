//
//  OnboardingExperience.swift
//  TimeDraw
//
//  Created by Michael Ellis on 9/11/22.
//

import SwiftUI

struct OnboardingExperience: View {
    
    var itemViewModel: ModifyCalendarItemViewModel
    var listViewModel: CalendarItemListViewModel
    
    @AppStorage(AppStorageKey.firstOpen) var isFirstAppOpen: Bool = true
    @State var currentPageIndex = 0
    
    @ViewBuilder static func overlayText(_ text: String) -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text(text)
                    .foregroundColor(.white)
                Spacer()
            }
            Spacer()
            Spacer()
        }
        .padding(18)
    }
    
    @ViewBuilder static func overlayScreenIndex(_ index: Int) -> some View {
        VStack {
            Spacer()
            Text("\(index)/4")
                .foregroundColor(.white)
            Text("Tap anywhere")
                .foregroundColor(.white)
            Spacer()
        }
        .padding(18)
    }
    
    func incrementOnboardingPage() {
        currentPageIndex += 1
        if currentPageIndex >= 6 {
            isFirstAppOpen = false
        }
    }
    
    var body: some View {
        VStack {
            switch currentPageIndex {
            case 0:
                IntroView(content: {
                    Text("Hey There 👋")
                    Text("Welcome to TimeDraw!")
                    Spacer()
                    Text("Tap anywhere")
                })
                .onTapGesture { incrementOnboardingPage() }
            case 1:
                IntroView(content: {
                    Text("Here's a quick intro to the app")
                    Text("")
                    Spacer()
                    Text("Tap anywhere")
                })
                .onTapGesture { incrementOnboardingPage() }
            case 2:
                DemoScreen(
                    aboveContent: EmptyView(),
                    content: MainHeader()
                        .environmentObject(listViewModel),
                    belowContent:
                        VStack {
                            OnboardingDailyGoalTextField()
                            TimeDrawClock(events: [], reminders: [])
                            EventInput()
                                .environmentObject(itemViewModel)
                        },
                    currentPageIndex: $currentPageIndex)
            case 3:
                DemoScreen(
                    aboveContent: MainHeader()
                        .environmentObject(listViewModel),
                    content: OnboardingDailyGoalTextField(),
                    belowContent:
                        VStack {
                            TimeDrawClock(events: [], reminders: [])
                            EventInput()
                                .environmentObject(itemViewModel)
                        },
                    currentPageIndex: $currentPageIndex)
            case 4:
                DemoScreen(
                    aboveContent:
                        VStack {
                            MainHeader()
                                .environmentObject(listViewModel)
                            OnboardingDailyGoalTextField()
                        },
                    content:
                        TimeDrawClock(events: [], reminders: []),
                    belowContent:
                        VStack {
                            EventInput()
                                .environmentObject(itemViewModel)
                        },
                    currentPageIndex: $currentPageIndex)
            case 5:
                DemoScreen(
                    aboveContent:
                        VStack {
                            MainHeader()
                                .environmentObject(listViewModel)
                            OnboardingDailyGoalTextField()
                            TimeDrawClock(events: [], reminders: [])
                        },
                    content: EventInput()
                        .environmentObject(itemViewModel),
                    belowContent: EmptyView(),
                    currentPageIndex: $currentPageIndex)
                .environmentObject(listViewModel)
            default:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .background(.black)
    }
}
