//
//  OnboardingPermissionPage.swift
//  Onboarding
//

import DesignToken
import EventKit
import SwiftUI
import AppCore

public struct OnboardingPermissionPage: View {
    
    public enum Kind {
        case event
        case reminder
    }
    
    let title: String
    let message: String
    let systemImage: String
    let eventKitManager: EventKitManager
    let onContinue: () -> Void
    let permissionKind: Kind

    @State private var isRequestingAccess = false
    @Binding private var  authorizationStatus: EKAuthorizationStatus

    public init(
        title: String,
        message: String,
        systemImage: String,
        authorizationStatus: Binding<EKAuthorizationStatus>,
        eventKitManager: EventKitManager,
        type: Kind,
        onContinue: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self._authorizationStatus = authorizationStatus
        self.eventKitManager = eventKitManager
        self.permissionKind = type
        self.onContinue = onContinue
    }

    private var accessGranted: Bool {
        switch permissionKind {
        case .event:
            eventKitManager.isEventAccessGranted(authorizationStatus)
        case .reminder:
            eventKitManager.isEventAccessGranted(authorizationStatus)
        }
    }

    public var body: some View {
        IntroView {
            VStack(spacing: 24) {
                Image(systemName: accessGranted ? "checkmark.circle.fill" : systemImage)
                    .font(.app(.iconLarge))
                    .foregroundStyle(accessGranted ? Color.green1 : Color.red1)

                Text(title)
                    .font(.app(.button))
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.app(.body))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                if accessGranted {
                    Text("Access granted")
                        .font(.app(.fine))
                        .foregroundStyle(Color.green1)
                }

                VStack(spacing: 12) {
                    if accessGranted {
                        Button("Continue", action: onContinue)
                            .buttonStyle(OnboardingPermissionPrimaryButtonStyle())
                    } else {
                        Button {
                            Task {
                                isRequestingAccess = true
                                switch permissionKind {
                                case .event:
                                    _ = try? await eventKitManager.requestEventAccess()
                                case .reminder:
                                    _ = try? await eventKitManager.requestReminderAccess()
                                }
                                authorizationStatus = eventKitManager.eventAuthorizationStatus()
                                isRequestingAccess = false
                                onContinue()
                            }
                        } label: {
                            if isRequestingAccess {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Allow Access")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(OnboardingPermissionPrimaryButtonStyle())
                        .disabled(isRequestingAccess)

                        Button("Not Now", action: onContinue)
                            .font(.app(.body))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 8)
        }
    }
}

private struct OnboardingPermissionPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.app(.button))
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .background(Color.red1.opacity(configuration.isPressed ? 0.85 : 1))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.listRowRadius, style: .continuous))
    }
}
