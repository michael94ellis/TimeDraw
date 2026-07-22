//
//  OnboardingExperience.swift
//  TimeDraw
//
//  Created by Michael Ellis on 9/11/22.
//

import Dependencies
import EventKit
import EventUIComponents
import SwiftUI
import DailyGoalTextfield

struct OnboardingExperience: View {
    var itemViewModel: ModifyCalendarItemViewModel
    var listViewModel: CalendarItemListViewModel

    @Dependency(\.eventKitManager) private var eventKitManager

    @AppStorage(AppStorageKey.firstOpen) var isFirstAppOpen: Bool = true
    @State var currentPageIndex = 0
    @State private var eventAuthStatus: EKAuthorizationStatus = .notDetermined
    @State private var reminderAuthStatus: EKAuthorizationStatus = .notDetermined

    private var usesTapToAdvance: Bool {
        currentPageIndex < 6
    }

    func finishOnboarding() {
        isFirstAppOpen = false
        listViewModel.updateData()
    }

    func incrementOnboardingPage() {
        guard usesTapToAdvance else { return }
        currentPageIndex += 1
    }

    func refreshEventAuthStatus() {
        eventAuthStatus = eventKitManager.eventAuthorizationStatus()
    }

    func refreshReminderAuthStatus() {
        reminderAuthStatus = eventKitManager.reminderAuthorizationStatus()
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
                Text("A space to write something about your day that doesn't fit as an Event or Reminder\n\nYou can hide this in settings") // swiftlint:disable:this line_length
                Spacer()
            }
        case 4:
            VStack(spacing: 16) {
                TimeDrawClock(events: [], reminders: [])
                Text("The Analog Clock - visualize your events and reminders from any calendars")
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
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

    @ViewBuilder
    var permissionScreenContent: some View {
        switch currentPageIndex {
        case 6:
            OnboardingPermissionPage(
                title: "Calendar Access",
                message: "TimeDraw shows your scheduled events on the analog clock and in your daily list.",
                systemImage: "calendar",
                authorizationStatus: eventAuthStatus,
                isAccessGranted: eventKitManager.isEventAccessGranted,
                onRequestAccess: {
                    _ = try? await eventKitManager.requestEventAccess()
                    refreshEventAuthStatus()
                },
                onContinue: {
                    currentPageIndex = 7
                    refreshReminderAuthStatus()
                }
            )
            .onAppear { refreshEventAuthStatus() }
        case 7:
            OnboardingPermissionPage(
                title: "Reminders Access",
                message: "TimeDraw displays your reminders alongside events so you can see your whole day at a glance.",
                systemImage: "checklist",
                authorizationStatus: reminderAuthStatus,
                isAccessGranted: eventKitManager.isReminderAccessGranted,
                onRequestAccess: {
                    _ = try? await eventKitManager.requestReminderAccess()
                    refreshReminderAuthStatus()
                },
                onContinue: finishOnboarding
            )
            .onAppear { refreshReminderAuthStatus() }
        default:
            EmptyView()
        }
    }

    var body: some View {
        ZStack {
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
                case 6, 7:
                    permissionScreenContent
                default:
                    VStack(spacing: 0) {
                        Spacer()
                        demoScreenContent
                            .allowsHitTesting(false)
                        Spacer()
                    }
                    .padding(24)
                }
            }
            .environmentObject(listViewModel)
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            if usesTapToAdvance {
                incrementOnboardingPage()
            }
        }
    }
}
