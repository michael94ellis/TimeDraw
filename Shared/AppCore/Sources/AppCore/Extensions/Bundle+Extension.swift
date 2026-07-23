//
//  Bundle+Extension.swift
//  AppCore
//
//  Created by Michael Ellis on 7/23/26.
//

import Foundation

extension Bundle {
    public var releaseVersionNumber: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    public var buildVersionNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? ""
    }
}
