//
//  CalendarItemType.swift
//  TimeDraw
//
//  Created by Michael Ellis on 7/12/25.
//

enum CalendarItemType: Int, CaseIterable {
    case scheduled = 0
    case all = 1
    case unscheduled = 2
    
    var displayName: String {
        switch(self) {
        case .scheduled: return "Scheduled"
        case .unscheduled: return "Unscheduled"
        case .all: return "&"
        }
    }
}
