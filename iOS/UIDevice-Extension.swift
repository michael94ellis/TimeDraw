//
//  UIDevice-Extension.swift
//  TimeDraw
//
//  Created by Michael Ellis on 9/17/22.
//

import UIKit

extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
    var topNotchHeight: CGFloat {
        return UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
    }
    var bottomNotchHeight: CGFloat {
        return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    }
}
