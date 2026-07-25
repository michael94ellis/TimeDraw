//
//  WatchEventKitAccessIndicators.swift
//  WatchFace
//

import DesignToken
import EventKit
import SwiftUI

/// Buttons to request calendar / reminders access when either is missing.
struct WatchEventKitAccessIndicators: View {
    
    let isEventAccessGranted: Bool
    let isReminderAccessGranted: Bool
    let requestEventAccess: () async -> Bool
    let requestReminderAccess: () async -> Bool
    
    @State private var isRequestingEvents = false
    @State private var isRequestingReminders = false
    
    var body: some View {
        if !isEventAccessGranted || !isReminderAccessGranted {
            VStack(spacing: 6) {
                if !isEventAccessGranted {
                    accessButton(
                        title: "Allow Events",
                        systemImage: "calendar",
                        isRequesting: isRequestingEvents
                    ) {
                        isRequestingEvents = true
                        _ = await requestEventAccess()
                        isRequestingEvents = false
                    }
                }
                if !isReminderAccessGranted {
                    accessButton(
                        title: "Allow Reminders",
                        systemImage: "checklist",
                        isRequesting: isRequestingReminders
                    ) {
                        isRequestingReminders = true
                        _ = await requestReminderAccess()
                        isRequestingReminders = false
                    }
                }
            }
        }
    }
    
    private func accessButton(
        title: String,
        systemImage: String,
        isRequesting: Bool,
        action: @escaping () async -> Void
    ) -> some View {
        Button {
            Task { await action() }
        } label: {
            HStack(spacing: 4) {
                if isRequesting {
                    ProgressView()
                } else {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
            .font(.system(size: 12, weight: .semibold))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(Colors.action)
        .disabled(isRequesting)
    }
}
