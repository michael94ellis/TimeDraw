//
//  EventKitPermissionPlaceholder.swift
//  TimeDraw
//

import EventKit
import SwiftUI

public struct EventKitPermissionPlaceholder: View {
    private let message: String
    private let authorizationStatus: EKAuthorizationStatus
    private let isAccessGranted: (EKAuthorizationStatus) -> Bool
    
    public init(
        message: String,
        authorizationStatus: EKAuthorizationStatus,
        isAccessGranted: @escaping (EKAuthorizationStatus) -> Bool
    ) {
        self.message = message
        self.authorizationStatus = authorizationStatus
        self.isAccessGranted = isAccessGranted
    }

    private var actionTitle: String {
        switch authorizationStatus {
        case .notDetermined:
            return "Allow Access"
        case .writeOnly:
            return "Allow Full Access"
        case .denied, .restricted:
            return "Open Settings"
        default:
            return "Allow Access"
        }
    }

    public var body: some View {
        if isAccessGranted(authorizationStatus) {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text(message)
                    .font(.interRegular)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                #if os(iOS)
                Button(action: openSettings) {
                    Text(actionTitle)
                        .frame(maxWidth: .infinity)
                }
                .font(.interSemiBold)
                .foregroundStyle(Color.blue1)
                .buttonStyle(.bordered)
                #endif
            }
            .padding(.vertical, 4)
        }
    }
    
    #if os(iOS)
    private func openSettings() {
        if #available(iOS 18.3, *) {
            guard let url = URL(string: UIApplication.openDefaultApplicationsSettingsURLString) else {
                assertionFailure()
                return
            }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                assertionFailure()
            }
        } else {
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                assertionFailure()
                return
            }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                assertionFailure()
            }
        }
    }
    #endif
}
