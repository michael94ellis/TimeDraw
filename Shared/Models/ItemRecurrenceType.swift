//
//  ItemRecurrenceType.swift
//  TimeDraw
//
//  Created by Michael Ellis on 7/12/25.
//

enum ItemRecurrenceType: Int, CaseIterable {
    case recurring = 0
    case all = 1
    case nonRecurring = 2
    
    var displayName: String {
        switch(self) {
        case .recurring: return "Recurring"
        case .nonRecurring: return "Non Recurring"
        case .all: return "&"
        }
    }
}
