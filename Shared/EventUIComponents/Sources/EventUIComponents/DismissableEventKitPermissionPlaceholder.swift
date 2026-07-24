//
//  DismissableEventKitPermissionPlaceholder.swift
//  TimeDraw
//

import EventKit
import DesignToken
import SwiftUI

public struct DismissableEventKitPermissionPlaceholder: View {
    let message: String
    let authorizationStatus: EKAuthorizationStatus
    let isAccessGranted: (EKAuthorizationStatus) -> Bool
    let requestAccess: () async -> Bool
    let onDismiss: () -> Void

    @State private var isVisible = true

    private let dismissAnimation = Animation.easeInOut(duration: 0.25)
    
    public init(message: String,
                authorizationStatus: EKAuthorizationStatus,
                isAccessGranted: @escaping (EKAuthorizationStatus) -> Bool,
                onDismiss: @escaping () -> Void,
                requestAccess: @escaping () async -> Bool,
                isVisible: Bool = true) {
        self.message = message
        self.authorizationStatus = authorizationStatus
        self.isAccessGranted = isAccessGranted
        self.onDismiss = onDismiss
        self.requestAccess = requestAccess
        self.isVisible = isVisible
    }

    public var body: some View {
        if isAccessGranted(authorizationStatus) {
            EmptyView()
        } else {
            ZStack(alignment: .leading) {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: dismissPlaceholder) {
                            Image(systemName: "xmark")
                                .font(.app(.icon))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .frame(width: 44, height: 44)
                    }
                    Spacer()
                }

                EventKitPermissionPlaceholder(
                    message: message,
                    authorizationStatus: authorizationStatus,
                    requestAccess: requestAccess
                )
                .padding(.trailing, 44)
                .padding(.vertical, 8)
            }
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.listRowRadius, style: .continuous)
                    .fill(Colors.listRowBackground)
            )
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.95, anchor: .top)
            .offset(y: isVisible ? 0 : -8)
            #if os(iOS)
            .listRowSeparator(.hidden)
            #endif
            .listRowBackground(EmptyView())
        }
    }

    private func dismissPlaceholder() {
        withAnimation(dismissAnimation) {
            isVisible = false
        }
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(250))
            onDismiss()
        }
    }
}
