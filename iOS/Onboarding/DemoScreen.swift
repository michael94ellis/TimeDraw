//
//  DemoScreen.swift
//  TimeDraw
//
//  Created by Michael Ellis on 9/18/22.
//

import SwiftUI

struct DemoScreen<Content: View, Above: View, Below: View>: View {
    
    var aboveContent: Above?
    var content: Content
    var belowContent: Below?
    
    @EnvironmentObject private var calendarItemListViewModel: CalendarItemListViewModel
    @Binding var isFirstAppOpen: Bool
    @Binding var currentPageIndex: Int
    
    func incrementOnboardingPage() {
        currentPageIndex += 1
        if currentPageIndex >= 6 {
            isFirstAppOpen = false
            calendarItemListViewModel.updateData()
        }
    }
    
    var body: some View {
        VStack {
            if let above = aboveContent {
                HStack {
                    Spacer()
                    above
                    Spacer()
                }
                .blur(radius: 3)
                .allowsHitTesting(false)
                .overlay(.black.opacity(0.72))
                .overlay(content: {
                    VStack {
                        if currentPageIndex == 4 {
                            OnboardingExperience.overlayText("The Analog Clock - visualize your events and reminders from any calendars\n\nYou can hide this in settings")
                        } else if currentPageIndex == 5 {
                            OnboardingExperience.overlayText("You can create events and reminders from TimeDraw as well")
                        }
                        if currentPageIndex >= 5 {
                            OnboardingExperience.overlayScreenIndex(currentPageIndex - 1)
                        }
                    }
                    .padding(.horizontal, 18)
                })
                .onTapGesture { incrementOnboardingPage() }
            }
            content
                .allowsHitTesting(false)
            Spacer()
            if let below = belowContent {
                HStack {
                    Spacer()
                    below
                    Spacer()
                }
                .blur(radius: 3)
                .allowsHitTesting(false)
                .overlay(.black.opacity(0.72))
                .overlay(content: {
                    VStack {
                        if currentPageIndex == 2 {
                            OnboardingExperience.overlayText("Here's a swipeable weekly calendar to quickly see and navigate through the weeks")
                        } else if currentPageIndex == 3 {
                            OnboardingExperience.overlayText("A space to write something about your day that doesn't fit as an Event or Reminder\n\nYou can hide this in settings")
                        }
                        if currentPageIndex < 5 {
                            OnboardingExperience.overlayScreenIndex(currentPageIndex - 1)
                        }
                    }
                    .padding(.horizontal, 18)
                })
                .onTapGesture { incrementOnboardingPage() }
            }
        }
    }
}
