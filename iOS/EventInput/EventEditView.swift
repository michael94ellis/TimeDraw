//
//  EventEditView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 7/15/26.
//

import EventKit
import EventKitUI
import SwiftUI

struct EventEditView: UIViewControllerRepresentable {
    let eventStore: EKEventStore
    /// Pass an existing event to edit, or `nil` to create a new one.
    var event: EKEvent?
    var onComplete: (EKEventEditViewAction) -> Void

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let controller = EKEventEditViewController()
        controller.eventStore = eventStore
        controller.event = event ?? EKEvent(eventStore: eventStore)
        controller.editViewDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }

    final class Coordinator: NSObject, EKEventEditViewDelegate {
        let onComplete: (EKEventEditViewAction) -> Void

        init(onComplete: @escaping (EKEventEditViewAction) -> Void) {
            self.onComplete = onComplete
        }

        func eventEditViewController(
            _ controller: EKEventEditViewController,
            didCompleteWith action: EKEventEditViewAction
        ) {
            onComplete(action)
        }
    }
}
