//
//  EventKitPermissionPlaceholder.swift
//  TimeDraw
//

import EventKit
import SwiftUI

struct EventKitPermissionPlaceholder: View {
    let message: String
    let authorizationStatus: EKAuthorizationStatus
    let isAccessGranted: (EKAuthorizationStatus) -> Bool

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

    var body: some View {
        if isAccessGranted(authorizationStatus) {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text(message)
                    .font(.interRegular)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: openSettings) {
                    Text(actionTitle)
                        .frame(maxWidth: .infinity)
                }
                .font(.interSemiBold)
                .foregroundStyle(Color.blue1)
                .buttonStyle(.bordered)
            }
            .padding(.vertical, 4)
        }
    }

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
}
