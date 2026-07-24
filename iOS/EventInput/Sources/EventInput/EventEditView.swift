//
//  EventEditView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 7/15/26.
//

import EventKit
import AppCore
import EventKitUI
import SwiftUI

public struct EventEditView: UIViewControllerRepresentable {
    let eventStore: EKEventStore
    /// Pass an existing event to edit, or `nil` to create a new one.
    var event: EKEvent?
    var onComplete: (EKEventEditViewAction) -> Void
    
    public init(eventStore: EKEventStore,
                event: EKEvent? = nil,
                onComplete: @escaping (EKEventEditViewAction) -> Void) {
        self.eventStore = eventStore
        self.event = event
        self.onComplete = onComplete
    }

    public func makeUIViewController(context: Context) -> EKEventEditViewController {
        let controller = EKEventEditViewController()
        controller.eventStore = eventStore
        controller.event = event ?? EKEvent(eventStore: eventStore)
        controller.editViewDelegate = context.coordinator
        return controller
    }

    public func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }

    final public class Coordinator: NSObject, EKEventEditViewDelegate {
        let onComplete: (EKEventEditViewAction) -> Void

        init(onComplete: @escaping (EKEventEditViewAction) -> Void) {
            self.onComplete = onComplete
        }

        public func eventEditViewController(
            _ controller: EKEventEditViewController,
            didCompleteWith action: EKEventEditViewAction
        ) {
            onComplete(action)
        }
    }
}
