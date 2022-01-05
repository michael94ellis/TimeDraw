//
//  Array-Extension.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/4/22.
//

import Foundation

extension Array where Element: Hashable {
    func uniqued<T: Equatable>(_ keyPath: KeyPath<Element, T>) -> [Element] {
        var buffer = Array()
        var added = Set<Element>()
        for elem in self {
            if !added.contains(where: { $0[keyPath: keyPath] == elem[keyPath: keyPath] }) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
}
