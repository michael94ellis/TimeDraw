//
//  Array+Extension.swift
//  AppCore
//
//  Created by Michael Ellis on 7/23/26.
//

extension Array {
    public func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
