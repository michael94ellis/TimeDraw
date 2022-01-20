//
//  SwiftBarButtonItem.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/6/22.
//

import UIKit

/// A solution for the lack of closures in UIBarButtonItems
class SwiftBarButtonItem: UIBarButtonItem {
    typealias ActionHandler = (UIBarButtonItem) -> Void

    private var actionHandler: ActionHandler?

    convenience init(image: UIImage?, style: UIBarButtonItem.Style, actionHandler: ActionHandler?) {
        self.init(image: image, style: style, target: nil, action: #selector(barButtonItemPressed(sender:)))
        target = self
        self.actionHandler = actionHandler
    }

    convenience init(title: String?, style: UIBarButtonItem.Style, actionHandler: ActionHandler?) {
        self.init(title: title, style: style, target: nil, action: #selector(barButtonItemPressed(sender:)))
        target = self
        self.actionHandler = actionHandler
    }

    convenience init(barButtonSystemItem systemItem: UIBarButtonItem.SystemItem, actionHandler: ActionHandler?) {
        self.init(barButtonSystemItem: systemItem, target: nil, action: #selector(barButtonItemPressed(sender:)))
        target = self
        self.actionHandler = actionHandler
    }

    @objc func barButtonItemPressed(sender: UIBarButtonItem) {
        actionHandler?(sender)
    }
}
