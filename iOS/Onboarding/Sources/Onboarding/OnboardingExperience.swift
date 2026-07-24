//
//  OnboardingExperience.swift
//  Onboarding
//
//  Created by Michael Ellis on 9/11/22.
//

import Dependencies
import EventInput
import AppCore
import DesignToken
import EventKit
import SwiftUI
import DailyGoalTextfield

public struct OnboardingExperience<HeaderDemo: View, ClockDemo: View>: View {
    enum Card {
        case welcome
        case intro
        case weeklyCalendar
        case dailyGoal
        case analogClock
        case eventCreation
        case calendarPermission
        case remindersPermission

        var advancesOnTap: Bool {
            switch self {
            case .calendarPermission, .remindersPermission:
                false
            default:
                true
            }
        }
    }

    var itemViewModel: ModifyCalendarItemViewModel
    var listViewModel: CalendarItemListViewModel
    @Binding var navPath: NavigationPath
    private let headerDemo: HeaderDemo
    private let clockDemo: ClockDemo

    @Dependency(\.eventKitManager) private var eventKitManager

    @State private var cards: [Card] = [
        .welcome,
        .intro,
        .weeklyCalendar,
        .dailyGoal,
        .analogClock,
        .eventCreation,
        .calendarPermission,
        .remindersPermission,
    ]
    @State private var eventAuthStatus: EKAuthorizationStatus = .notDetermined
    @State private var reminderAuthStatus: EKAuthorizationStatus = .notDetermined

    private var currentCard: Card? {
        cards.first
    }

    public init(
        itemViewModel: ModifyCalendarItemViewModel,
        listViewModel: CalendarItemListViewModel,
        navPath: Binding<NavigationPath>,
        @ViewBuilder headerDemo: () -> HeaderDemo,
        @ViewBuilder clockDemo: () -> ClockDemo
    ) {
        self.itemViewModel = itemViewModel
        self.listViewModel = listViewModel
        self._navPath = navPath
        self.headerDemo = headerDemo()
        self.clockDemo = clockDemo()
    }

    func finishOnboarding() {
        AppSettings().isFirstAppOpen = false
        listViewModel.updateData()
        navPath.removeLast()
    }

    func advanceOnboarding() {
        guard !cards.isEmpty else { return }
        cards.removeFirst()
        if cards.isEmpty {
            finishOnboarding()
        }
    }

    func refreshEventAuthStatus() {
        eventAuthStatus = eventKitManager.eventAuthorizationStatus()
    }

    func refreshReminderAuthStatus() {
        reminderAuthStatus = eventKitManager.reminderAuthorizationStatus()
    }

    @ViewBuilder
    func cardContent(_ card: Card) -> some View {
        switch card {
        case .welcome:
            IntroView {
                Text("Hey There 👋\nWelcome to TimeDraw!\n\n\n\nTap anywhere")
                    .multilineTextAlignment(.center)
            }
        case .intro:
            IntroView {
                Text("Here's a quick intro to the app\n\n\n\n\n\nTap anywhere")
                    .multilineTextAlignment(.center)
            }
        case .weeklyCalendar:
            VStack {
                headerDemo
                    .environmentObject(listViewModel)

                Text("Here's a swipeable weekly calendar to quickly see and navigate through the weeks")
                Spacer()
            }
            .padding(24)
            .allowsHitTesting(false)
        case .dailyGoal:
            VStack {
                OnboardingDailyGoalTextField()
                Text("A space to write something about your day that doesn't fit as an Event or Reminder\n\nYou can hide this in settings") // swiftlint:disable:this line_length
                Spacer()
            }
            .padding(24)
            .allowsHitTesting(false)
        case .analogClock:
            VStack(spacing: 16) {
                clockDemo
                Text("The Analog Clock - visualize your events and reminders from any calendars")
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .allowsHitTesting(false)
        case .eventCreation:
            VStack {
                Spacer()
                Text("You can create events and reminders from TimeDraw as well")
                EventInput(eventCreationAction: {
                    // TODO: Add create event demo experienc with confetti
                })
                    .environmentObject(itemViewModel)
            }
            .padding(24)
            .allowsHitTesting(false)
        case .calendarPermission:
            OnboardingPermissionPage(
                title: "Calendar Access",
                message: "TimeDraw shows your scheduled events on the analog clock and in your daily list.",
                systemImage: "calendar",
                authorizationStatus: $eventAuthStatus,
                eventKitManager: eventKitManager,
                type: .event,
                onContinue: {
                    advanceOnboarding()
                    refreshReminderAuthStatus()
                }
            )
            .onAppear { refreshEventAuthStatus() }
        case .remindersPermission:
            OnboardingPermissionPage(
                title: "Reminders Access",
                message: "TimeDraw displays your reminders alongside events so you can see your whole day at a glance.",
                systemImage: "checklist",
                authorizationStatus: $reminderAuthStatus,
                eventKitManager: eventKitManager,
                type: .reminder,
                onContinue: advanceOnboarding
            )
            .onAppear { refreshReminderAuthStatus() }
        }
    }

    public var body: some View {
        ZStack {
            Color.systemBackground.ignoresSafeArea()

            VStack {
                if let currentCard {
                    cardContent(currentCard)
                }
            }
            .environmentObject(listViewModel)
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            guard let currentCard, currentCard.advancesOnTap else { return }
            advanceOnboarding()
        }
    }
}
