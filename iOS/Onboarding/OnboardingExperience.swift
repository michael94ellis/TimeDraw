//
//  OnboardingExperience.swift
//  TimeDraw
//
//  Created by Michael Ellis on 9/11/22.
//

import SwiftUI

struct OnboardingExperience: View {
    
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
                .font(.interFine)
            Text("Tap anywhere")
                .foregroundColor(.white)
                .font(.interFine)
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
                        .font(.interFine)
                })
                .onTapGesture { incrementOnboardingPage() }
            case 1:
                IntroView(content: {
                    Text("Here's a quick intro to the app")
                    Text("")
                    Spacer()
                    Text("Tap anywhere")
                        .font(.interFine)
                })
                .onTapGesture { incrementOnboardingPage() }
            case 2:
                DemoScreen(
                    aboveContent: EmptyView(),
                    content: MainHeader(),
                    belowContent:
                        VStack {
                            OnboardingDailyGoalTextField()
                            TimeDrawClock(width: 120)
                            EventInput()
                        },
                    currentPageIndex: $currentPageIndex)
            case 3:
                DemoScreen(
                    aboveContent: MainHeader(),
                    content: OnboardingDailyGoalTextField(),
                    belowContent:
                        VStack {
                            TimeDrawClock(width: 120)
                            EventInput()
                        },
                    currentPageIndex: $currentPageIndex)
            case 4:
                DemoScreen(
                    aboveContent:
                        VStack {
                            MainHeader()
                            OnboardingDailyGoalTextField()
                        },
                    content:
                        TimeDrawClock(width: 120),
                    belowContent:
                        VStack {
                            EventInput()
                        },
                    currentPageIndex: $currentPageIndex)
            case 5:
                DemoScreen(
                    aboveContent:
                        VStack {
                            MainHeader()
                            OnboardingDailyGoalTextField()
                            TimeDrawClock(width: 120)
                        },
                    content: EventInput(),
                    belowContent: EmptyView(),
                    currentPageIndex: $currentPageIndex)
            default:
                EmptyView()
            }
        }
        .contentShape(Rectangle())
    }
}
