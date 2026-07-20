//
//  Time.swift
//  TimeDraw
//
//  Created by Michael Ellis on 7/11/25.
//

public struct Time {
    public var sec: Int
    public var min: Int
    public var hour: Int
    
    public init(sec: Int,
                min: Int,
                hour: Int) {
        self.sec = sec
        self.min = min
        self.hour = hour
    }
}
