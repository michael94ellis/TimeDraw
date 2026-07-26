//
//  PhoneWatchSync.swift
//  AppCore
//
//  Mirrors selected calendar IDs and highlight color from iPhone → Watch via
//  WatchConnectivity. Event/reminder *content* still comes from each device’s
//  EventKit store.
//

import Foundation
import WatchConnectivity

public enum PhoneWatchSyncKey {
    public static let selectedCalendarIDs = "selectedCalendarIDs"
    public static let highlightColorHex = "highlightColorHex"
}

#if os(watchOS)
/// Latest calendar selection received from the iPhone (persisted locally).
@MainActor
@Observable
public final class MirroredCalendarSelection {
    public static let shared = MirroredCalendarSelection()
    
    public private(set) var selectedCalendarIDs: [String]
    
    private static let defaultsKey = "mirroredSelectedCalendarIDs"
    
    private init() {
        selectedCalendarIDs = UserDefaults.standard.stringArray(forKey: Self.defaultsKey) ?? []
    }
    
    public func apply(_ ids: [String]) {
        guard ids != selectedCalendarIDs else { return }
        selectedCalendarIDs = ids
        UserDefaults.standard.set(ids, forKey: Self.defaultsKey)
    }
}

/// Latest highlight color received from the iPhone (persisted locally).
@MainActor
@Observable
public final class MirroredHighlightColor {
    public static let shared = MirroredHighlightColor()
    
    public private(set) var hex: String
    
    private static let defaultsKey = "mirroredHighlightColorHex"
    
    private init() {
        hex = UserDefaults.standard.string(forKey: Self.defaultsKey)
            ?? AppSettings.defaultHighlightColorHex
    }
    
    public func apply(_ hex: String) {
        guard hex != self.hex else { return }
        self.hex = hex
        UserDefaults.standard.set(hex, forKey: Self.defaultsKey)
    }
}
#endif

/// Activates `WCSession` and syncs preferences iPhone → Watch.
public final class PhoneWatchSync: NSObject, WCSessionDelegate, @unchecked Sendable {
    public static let shared = PhoneWatchSync()
    
    #if os(iOS)
    private let lock = NSLock()
    /// Both keys are always sent together — `updateApplicationContext` replaces the whole dictionary.
    private var pendingCalendarIDs: [String] = []
    private var pendingHighlightColorHex: String = UserDefaults.appGroup.string(forKey: AppStorageKey.highlightColorHex)
        ?? AppSettings.defaultHighlightColorHex
    private var hasPendingTransfer = false
    #endif
    
    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
    
    /// Ensures the shared session is created and activating.
    public func activate() {
        _ = Self.shared
    }
    
    #if os(iOS)
    /// Pushes the phone’s selected calendar IDs to the watch (latest-wins).
    public func syncSelectedCalendars(_ ids: [String]) {
        lock.lock()
        pendingCalendarIDs = ids
        hasPendingTransfer = true
        lock.unlock()
        pushPendingIfPossible()
    }
    
    /// Pushes the phone’s highlight color to the watch (latest-wins).
    public func syncHighlightColor(_ hex: String) {
        lock.lock()
        pendingHighlightColorHex = hex
        hasPendingTransfer = true
        lock.unlock()
        pushPendingIfPossible()
    }
    
    private func pushPendingIfPossible() {
        guard WCSession.isSupported() else { return }
        lock.lock()
        guard hasPendingTransfer else {
            lock.unlock()
            return
        }
        let ids = pendingCalendarIDs
        let hex = pendingHighlightColorHex
        lock.unlock()
        
        let session = WCSession.default
        guard session.activationState == .activated else { return }
        
        let context: [String: Any] = [
            PhoneWatchSyncKey.selectedCalendarIDs: ids,
            PhoneWatchSyncKey.highlightColorHex: hex
        ]
        do {
            try session.updateApplicationContext(context)
        } catch {
            // Duplicate context (unchanged dictionary) can throw; safe to ignore.
        }
    }
    #endif
    
    #if os(watchOS)
    private func handleContext(_ context: [String: Any]) {
        let ids = context[PhoneWatchSyncKey.selectedCalendarIDs] as? [String] ?? []
        let hex = context[PhoneWatchSyncKey.highlightColorHex] as? String
        Task { @MainActor in
            MirroredCalendarSelection.shared.apply(ids)
            if let hex {
                MirroredHighlightColor.shared.apply(hex)
            }
        }
    }
    #endif
    
    // MARK: - WCSessionDelegate
    
    public func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        #if os(iOS)
        if activationState == .activated {
            pushPendingIfPossible()
        }
        #endif
        #if os(watchOS)
        handleContext(session.receivedApplicationContext)
        #endif
    }
    
    public func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        #if os(watchOS)
        handleContext(applicationContext)
        #endif
    }
    
    #if os(iOS)
    public func sessionDidBecomeInactive(_ session: WCSession) {}
    
    public func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    #endif
}
