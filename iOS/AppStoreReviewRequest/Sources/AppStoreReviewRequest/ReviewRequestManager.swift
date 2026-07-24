//
//  ReviewRequestManager.swift
//  TimeDraw
//
//  Created by Michael Ellis on 7/26/25.
//

import Foundation
import StoreKit
import SwiftUI
import UIKit

final public class ReviewRequestManager: ReviewRequestManageable {
        
    private let firstLaunchKey = "timedraw.firstLaunchDate"
    private let triggerDays: Double = 30
    
    public init() { }
    
    public func requestReviewIfAppropriate(for userDefaults: UserDefaults) {
        let now = Date()
        
        // Save first launch date if not already stored
        if userDefaults.object(forKey: firstLaunchKey) == nil {
            userDefaults.set(now, forKey: firstLaunchKey)
            return
        }
        
        guard let launchDate = userDefaults.object(forKey: firstLaunchKey) as? Date else {
            return
        }
        
        let daysSinceLaunch = now.timeIntervalSince(launchDate) / (60 * 60 * 24)
        guard daysSinceLaunch >= triggerDays else {
            return
        }
        
        requestReview()
    }
    
    func requestReview() {
        Task { @MainActor in
            guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                assertionFailure()
                return
            }
            AppStore.requestReview(in: window)
        }
    }
}
