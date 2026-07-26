//
//  PhoneWatchSync.swift
//  AppCore
//
//  Mirrors selected calendar IDs from iPhone → Watch via WatchConnectivity.
//  Event/reminder *content* still comes from each device’s EventKit store.
//

import Foundation
import WatchConnectivity

public enum PhoneWatchSyncKey {
    public static let selectedCalendarIDs = "selectedCalendarIDs"
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
#endif

/// Activates `WCSession` and syncs selected calendar IDs iPhone → Watch.
public final class PhoneWatchSync: NSObject, WCSessionDelegate, @unchecked Sendable {
    public static let shared = PhoneWatchSync()
    
    #if os(iOS)
    private let lock = NSLock()
    private var pendingCalendarIDs: [String]?
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
        lock.unlock()
        pushPendingIfPossible()
    }
    
    private func pushPendingIfPossible() {
        guard WCSession.isSupported() else { return }
        lock.lock()
        let ids = pendingCalendarIDs
        lock.unlock()
        guard let ids else { return }
        
        let session = WCSession.default
        guard session.activationState == .activated else { return }
        
        let context: [String: Any] = [PhoneWatchSyncKey.selectedCalendarIDs: ids]
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
        Task { @MainActor in
            MirroredCalendarSelection.shared.apply(ids)
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
