//
//  OnboardingPermissionPage.swift
//  Onboarding
//

import DesignToken
import EventKit
import SwiftUI

public struct OnboardingPermissionPage: View {
    let title: String
    let message: String
    let systemImage: String
    let authorizationStatus: EKAuthorizationStatus
    let isAccessGranted: (EKAuthorizationStatus) -> Bool
    let onRequestAccess: () async -> Void
    let onContinue: () -> Void

    @State private var isRequestingAccess = false

    public init(
        title: String,
        message: String,
        systemImage: String,
        authorizationStatus: EKAuthorizationStatus,
        isAccessGranted: @escaping (EKAuthorizationStatus) -> Bool,
        onRequestAccess: @escaping () async -> Void,
        onContinue: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.authorizationStatus = authorizationStatus
        self.isAccessGranted = isAccessGranted
        self.onRequestAccess = onRequestAccess
        self.onContinue = onContinue
    }

    private var accessGranted: Bool {
        isAccessGranted(authorizationStatus)
    }

    public var body: some View {
        IntroView {
            VStack(spacing: 24) {
                Image(systemName: accessGranted ? "checkmark.circle.fill" : systemImage)
                    .font(.system(size: 56))
                    .foregroundStyle(accessGranted ? Color.green1 : Color.red1)

                Text(title)
                    .font(.interSemiBold)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.interRegular)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                if accessGranted {
                    Text("Access granted")
                        .font(.interFine)
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
                                await onRequestAccess()
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
                            .font(.interRegular)
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
            .font(.interSemiBold)
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .background(Color.red1.opacity(configuration.isPressed ? 0.85 : 1))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.listRowRadius, style: .continuous))
    }
}
