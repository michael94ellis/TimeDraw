//
//  OnboardingExperience.swift
//  TimeDraw
//
//  Created by Michael Ellis on 9/11/22.
//

import SwiftUI

struct OnboardingExperience: View {
    
    @Binding var isFirstAppOpen: Bool
    @State var currentPageIndex = 0
    
    @ViewBuilder var welcomeView: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Spacer()
                Text("Hey There 👋")
                Text("Welcome to TimeDraw!")
                Spacer()
                Text("Tap anywhere")
                    .font(.interFine)
                Spacer()
            }
            Spacer()
        }
        .background(.background)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            currentPageIndex += 1
        }
    }
    
    @ViewBuilder var introView: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Spacer()
                Text("Here's a quick intro to the app")
                Spacer()
                Text("Tap anywhere")
                    .font(.interFine)
                Spacer()
            }
            Spacer()
        }
        .background(.background)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            currentPageIndex += 1
        }
    }
    
    @ViewBuilder var previewOfHomePage: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
            }
            Spacer()
        }
        .background(.gray.opacity(0.1))
        .onAppear(perform: { Task { await delayAction { currentPageIndex = 3 } } })
    }
    
    @ViewBuilder var miniCalendarView: some View {
        VStack {
            MainHeader()
                .allowsHitTesting(false)
            VStack {
                Text("Here's a simple mini calendar to quickly see and navigate through the week")
                Spacer()
                Spacer()
                Text("1/4")
                    .font(.interFine)
                Text("Tap anywhere")
                    .font(.interFine)
                Spacer()
            }
            .padding(12)
            .background(.thickMaterial)
            .onTapGesture {
                currentPageIndex += 1
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder var dailyGoalWritingSpace: some View {
        VStack {
            MainHeader()
                .allowsHitTesting(false)
                .overlay(.gray.opacity(0.85))
            OnboardingDailyGoalTextField()
                .allowsHitTesting(false)
                .background(.background)
            VStack {
                VStack(alignment: .leading) {
                    Text("A space to write something about your day that doesn't fit as an Event or Reminder\n")
                    Text("You can hide this in settings")
                }
                Spacer()
                Spacer()
                Text("2/4")
                    .font(.interFine)
                Text("Tap anywhere")
                    .font(.interFine)
                Spacer()
            }
            .padding(12)
            .background(.thickMaterial)
            .onTapGesture {
                currentPageIndex += 1
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder var analogClockFace: some View {
        VStack {
            ZStack {
                VStack {
                    MainHeader()
                    OnboardingDailyGoalTextField()
                }
                .allowsHitTesting(false)
                .overlay(.gray.opacity(0.97))
                .background(.background)
                VStack(alignment: .leading) {
                    Text("The Analog Clock - visualize your events and reminders from calendars linked to your device's Apple Account\n")
                    Text("You can hide this in settings")
                }
                .padding(18)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                currentPageIndex += 1
            }
            TimeDrawClock(showClockView: Binding<Bool>(get: { true }, set: { _ in }), width: 120)
                .allowsHitTesting(false)
                .background(.background)
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Spacer()
                    Text("3/4")
                        .font(.interFine)
                    Text("Tap anywhere")
                        .font(.interFine)
                    Spacer()
                }
                Spacer()
            }
            .padding(12)
            .background(.thickMaterial)
            .onTapGesture {
                currentPageIndex += 1
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder var howToCreateEvents: some View {
        VStack {
            ZStack {
                VStack {
                    MainHeader()
                    OnboardingDailyGoalTextField()
                    TimeDrawClock(showClockView: Binding<Bool>(get: { true }, set: { _ in }), width: 120)
                        .allowsHitTesting(false)
                        .background(.background)
                }
                .allowsHitTesting(false)
                .overlay(.gray.opacity(0.97))
                .background(.background)
                VStack(alignment: .leading) {
                    Spacer()
                    Text("You can create events and reminders from TimeDraw as well")
                    Spacer()
                    Spacer()
                }
                .padding(18)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                currentPageIndex += 1
            }
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Spacer()
                    Text("4/4")
                        .font(.interFine)
                    Text("Tap anywhere")
                        .font(.interFine)
                    Spacer()
                    EventInput(isBackgroundBlurred: Binding<Bool>(get: { true }, set: { _ in }))
                        .allowsHitTesting(false)
                }
                Spacer()
            }
            .padding(12)
            .background(.thickMaterial)
            .onTapGesture {
                isFirstAppOpen = false
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func delayAction(_ completion: @escaping () -> ()) async {
        // Delay of 7.5 seconds (1 second = 1_000_000_000 nanoseconds)
        try? await Task.sleep(nanoseconds: 500_000_000)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            completion()
        }
    }
    
    var body: some View {
        VStack {
            switch currentPageIndex {
            case 0: welcomeView
            case 1: introView
            case 2: previewOfHomePage
            case 3: miniCalendarView
            case 4: dailyGoalWritingSpace
            case 5: analogClockFace
            case 6: howToCreateEvents
            default:
                EmptyView()
            }
        }
        .contentShape(Rectangle())
    }
}
