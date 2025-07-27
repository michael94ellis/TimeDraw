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

@MainActor
final class ReviewRequestManager {
    
    static let shared = ReviewRequestManager()
    
    private let firstLaunchKey = "timedraw.firstLaunchDate"
    private let triggerDays: Double = 30

    func requestReviewIfAppropriate() {
        let now = Date()
        let defaults = UserDefaults.standard

        // Save first launch date if not already stored
        if defaults.object(forKey: firstLaunchKey) == nil {
            defaults.set(now, forKey: firstLaunchKey)
            return
        }

        guard let launchDate = defaults.object(forKey: firstLaunchKey) as? Date else {
            return
        }
        
        let daysSinceLaunch = now.timeIntervalSince(launchDate) / (60 * 60 * 24)
        guard daysSinceLaunch >= triggerDays else {
            return
        }

        requestReview()
    }
    
    func requestReview() {
        #if !os(watchOS)
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            assertionFailure()
            return
        }
        AppStore.requestReview(in: window)
        #endif
    }
}
