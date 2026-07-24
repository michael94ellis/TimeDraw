//
//  DesignForm.swift
//  DesignToken
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Device form factor used for typography and chrome scale.
/// Resolved by the package from OS / idiom — not from size class.
public enum DesignForm: Sendable {
    case phone
    case pad
    case watch

    public static var current: DesignForm {
        #if os(watchOS)
        .watch
        #elseif os(iOS)
        UIDevice.current.userInterfaceIdiom == .pad ? .pad : .phone
        #else
        .phone
        #endif
    }
}
