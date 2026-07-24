//
//  ReviewRequestManageable.swift
//  AppStoreReviewRequest
//
//  Created by Michael Ellis on 7/23/26.
//

import Foundation

public protocol ReviewRequestManageable {
    func requestReviewIfAppropriate(for userDefaults: UserDefaults)
}
