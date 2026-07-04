//
//  DismissableEventKitPermissionPlaceholder.swift
//  TimeDraw
//

import EventKit
import SwiftUI

struct DismissableEventKitPermissionPlaceholder: View {
    let message: String
    let authorizationStatus: EKAuthorizationStatus
    let isAccessGranted: (EKAuthorizationStatus) -> Bool
    let onDismiss: () -> Void

    @State private var isVisible = true

    private let dismissAnimation = Animation.easeInOut(duration: 0.25)

    var body: some View {
        if isAccessGranted(authorizationStatus) {
            EmptyView()
        } else {
            ZStack(alignment: .leading) {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: dismissPlaceholder) {
                            Image(systemName: "xmark")
                                .font(.headline)
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
                    isAccessGranted: isAccessGranted
                )
                .padding(.trailing, 44)
                .padding(.vertical, 8)
            }
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
            )
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.95, anchor: .top)
            .offset(y: isVisible ? 0 : -8)
            .listRowSeparator(.hidden)
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
