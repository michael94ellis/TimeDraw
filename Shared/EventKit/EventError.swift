//
//  EventError.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/4/22.
//

import EventKit
import SwiftUI

/// EventError definition
public enum EventError: Error, LocalizedError {
    case mapFromError(Error)
    case unableToAccessCalendar
    case eventAuthorizationStatus(EKAuthorizationStatus)
    case invalidEvent
    
    var localizedDescription: String {
        switch self {
        case .invalidEvent: return "Invalid event"
        case .unableToAccessCalendar: return "Unable to access calendar"
        case let .mapFromError(error): return error.localizedDescription
        case let .eventAuthorizationStatus(status): return "Permission not granted, auth status: \(status)"
        }
    }
}

extension NSError {
    /// For displaying an error message to users from EventKit APIs
    var displayEKErrorDescription: String {
        switch self.code {
        case 0: return "eventNotMutable"
        case 1: return "Please Select A Calendar"
        case 2: return "No Start Date"
        case 3: return "No End Date"
        case 4: return "End date before start"
        case 5: return "Warning: Device Internal Failure"
        case 6: return "Calendar is Read Only"
        case 7: return "Duration Greater Than Recurrence"
        case 8: return "Alarm Greater Than Recurrence"
        case 9: return "Start Date TooFar In Future"
        case 10: return "Start Date Collides With Other Occurrence"
        case 11: return "Object Belongs To DifferentStore"
        case 12: return "Invites Cannot Be Moved"
        case 13: return "Invalid Span"
        case 14: return "Calendar Has No Source"
        case 15: return "Source Cannot Be Modified"
        case 16: return "Calendar Cannot Be Modified"
        case 17: return "Calendar Add/Delete Not Allowed"
        case 18: return "Recurring Reminder Requires Due Date"
        case 19: return "Structured Locations Not Supported"
        case 20: return "Reminder Locations Not Supported"
        case 21: return "Alarm Proximity Not Supported"
        case 22: return "Please Select Events Calendar"
        case 23: return "Please Select Reminders Calendar"
        case 24: return "Please Select Reminders Calendar"
        case 25: return "Source Does Not Allow Events"
        case 26: return "Priority Is Invalid"
        case 27: return "Invalid Entity Type"
        case 28: return "Procedure Alarms Not Mutable"
        case 29: return "Event Store Not Authorized"
        case 30: return "os Not Supported"
        case 31: return "Invalid Invite Reply Calendar"
        case 32: return "Notifications Collection Flag Not Set"
        case 33: return "Source Mismatch"
        case 34: return "Motification Collection Mismatch"
        case 35: return "Notification Saved Without Collection"
        case 36: return "Reminder Alarm Contains Email or Url"
        default: return "Error: \(self.code)"
        }
    }
}
