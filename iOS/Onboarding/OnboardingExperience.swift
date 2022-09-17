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
    
    @ViewBuilder var miniCalendarView: some View {
        VStack {
            MainHeader()
                .allowsHitTesting(false)
            HStack {
                Spacer()
                VStack {
                    VStack {
                        OnboardingDailyGoalTextField()
                        TimeDrawClock(showClockView: Binding<Bool>(get: { true }, set: { _ in }), width: 120)
                    }
                    .allowsHitTesting(false)
                    .blur(radius: 3)
                    Spacer()
                }
                Spacer()
            }
            .overlay(.black.opacity(0.72))
            .overlay(content: {
                VStack {
                    Spacer()
                    Spacer()
                    Text("Here's a simple mini calendar to quickly see and navigate through the week")
                        .foregroundColor(.white)
                    Spacer()
                    Spacer()
                    Text("1/4")
                        .foregroundColor(.white)
                        .font(.interFine)
                    Text("Tap anywhere")
                        .foregroundColor(.white)
                        .font(.interFine)
                    Spacer()
                }
                .padding(18)
            })
            .onTapGesture {
                currentPageIndex += 1
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder var dailyGoalWritingSpace: some View {
        VStack {
            HStack {
                Spacer()
                VStack {
                    VStack {
                        MainHeader()
                            .blur(radius: 3)
                            .allowsHitTesting(false)
                    }
                }
                Spacer()
            }
            .overlay(.black.opacity(0.72))
            OnboardingDailyGoalTextField()
                .allowsHitTesting(false)
            HStack {
                Spacer()
                VStack {
                    TimeDrawClock(showClockView: Binding<Bool>(get: { true }, set: { _ in }), width: 120)
                        .blur(radius: 3)
                        .allowsHitTesting(false)
                    Spacer()
                }
                Spacer()
            }
            .overlay(.black.opacity(0.72))
            .overlay(content: {
                VStack {
                    Spacer()
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("A space to write something about your day that doesn't fit as an Event or Reminder\n\nYou can hide this in settings")
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Spacer()
                    Text("2/4")
                        .foregroundColor(.white)
                        .font(.interFine)
                    Text("Tap anywhere")
                        .foregroundColor(.white)
                        .font(.interFine)
                    Spacer()
                }
                .padding(18)
            })
            .onTapGesture {
                currentPageIndex += 1
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder var analogClockFace: some View {
        VStack {
            HStack {
                Spacer()
                VStack {
                    VStack {
                        MainHeader()
                        OnboardingDailyGoalTextField()
                    }
                }
                Spacer()
            }
            .allowsHitTesting(false)
            .blur(radius: 3)
            .overlay(.black.opacity(0.72))
            .contentShape(Rectangle())
            .onTapGesture {
                currentPageIndex += 1
            }
            TimeDrawClock(showClockView: Binding<Bool>(get: { true }, set: { _ in }), width: 120)
                .allowsHitTesting(false)
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Text("The Analog Clock - visualize your events and reminders from calendars linked to your device's Apple Account\n\nYou can hide this in settings")
                        .foregroundColor(.white)
                        .frame(alignment: .leading)
                    Spacer()
                    Text("3/4")
                        .foregroundColor(.white)
                        .font(.interFine)
                    Text("Tap anywhere")
                        .foregroundColor(.white)
                        .font(.interFine)
                    Spacer()
                }
                Spacer()
            }
            .padding(18)
            .background(.black.opacity(0.72))
            .onTapGesture {
                currentPageIndex += 1
            }
        }
    }
    
    @ViewBuilder var howToCreateEvents: some View {
        VStack {
            HStack {
                Spacer()
                VStack {
                    VStack {
                        MainHeader()
                        OnboardingDailyGoalTextField()
                        TimeDrawClock(showClockView: Binding<Bool>(get: { true }, set: { _ in }), width: 120)
                    }
                    .allowsHitTesting(false)
                    .blur(radius: 8)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    currentPageIndex += 1
                }
                Spacer()
            }
            .padding(12)
            .overlay(.black.opacity(0.72))
            .overlay(content: {
                VStack {
                    Spacer()
                    Spacer()
                    Spacer()
                    Text("You can create events and reminders from TimeDraw as well")
                        .foregroundColor(.white)
                    Spacer()
                    Text("4/4")
                        .foregroundColor(.white)
                        .font(.interFine)
                    Text("Tap anywhere")
                        .foregroundColor(.white)
                        .font(.interFine)
                    Spacer()
                }
            })
            .onTapGesture {
                isFirstAppOpen = false
            }
            EventInput()
                .allowsHitTesting(false)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var body: some View {
        VStack {
            switch currentPageIndex {
            case 0: welcomeView
            case 1: introView
            case 2: miniCalendarView
            case 3: dailyGoalWritingSpace
            case 4: analogClockFace
            case 5: howToCreateEvents
            default:
                EmptyView()
                    .onAppear(perform: {
                        isFirstAppOpen = false
                    })
            }
        }
        .contentShape(Rectangle())
    }
}
