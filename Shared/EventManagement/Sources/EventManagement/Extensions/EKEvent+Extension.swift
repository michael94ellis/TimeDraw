import EventKit
import UIKit

extension EKEvent {
    public static func mock(startHour: Int, endHour: Int, color: UIColor) -> EKEvent {
        let store = EKEventStore()
        let event = EKEvent(eventStore: store)
        let today = Calendar.current.startOfDay(for: Date())
        event.startDate = today.addingTimeInterval(TimeInterval(startHour * 3600))
        event.endDate = today.addingTimeInterval(TimeInterval(endHour * 3600))
        let calendar = EKCalendar(for: .event, eventStore: store)
        calendar.cgColor = color.cgColor
        event.calendar = calendar
        return event
    }
}
