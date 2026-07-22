//
//  DebugTestDataSeeder.swift
//  TimeDraw
//

#if DEBUG
import Dependencies
import EventKit
import SwiftUI

enum DebugTestDataSeeder {

    static let titlePrefix = "[Debug]"

    enum SeederError: LocalizedError {
        case accessDenied
        case missingCalendar

        var errorDescription: String? {
            switch self {
            case .accessDenied: return "Calendar or Reminders access was denied."
            case .missingCalendar: return "Could not find or create a TimeDraw calendar."
            }
        }
    }

    static func seed(using eventStore: EKEventStore) async throws -> (events: Int, reminders: Int) {
        try await requestAccess(using: eventStore)

        guard let eventCalendar = calendar(for: .event, eventStore: eventStore),
              let reminderCalendar = calendar(for: .reminder, eventStore: eventStore) else {
            throw SeederError.missingCalendar
        }

        let eventCount = try seedEvents(using: eventStore, calendar: eventCalendar)
        let reminderCount = try seedReminders(using: eventStore, calendar: reminderCalendar)
        return (eventCount, reminderCount)
    }

    // MARK: - Authorization

    private static func requestAccess(using eventStore: EKEventStore) async throws {
        guard try await eventStore.requestFullAccessToEvents(),
              try await eventStore.requestFullAccessToReminders() else {
            throw SeederError.accessDenied
        }
    }

    // MARK: - Calendars

    private static func calendar(for entityType: EKEntityType, eventStore: EKEventStore) -> EKCalendar? {
        let appName = EventKitManager.appName
        let calendars = eventStore.calendars(for: entityType)
        if let existing = calendars.first(where: { $0.title == appName }) {
            return existing
        }

        let newCalendar = EKCalendar(for: entityType, eventStore: eventStore)
        newCalendar.title = appName
        newCalendar.source = eventStore.defaultCalendarForNewEvents?.source
        newCalendar.cgColor = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
        do {
            try eventStore.saveCalendar(newCalendar, commit: true)
            return newCalendar
        } catch {
            return eventStore.defaultCalendarForNewEvents
        }
    }

    // MARK: - Events

    private static func seedEvents(using eventStore: EKEventStore, calendar: EKCalendar) throws -> Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        guard let rangeStart = cal.date(byAdding: .day, value: -10, to: today),
              let rangeEnd = cal.date(byAdding: .day, value: 30, to: today) else {
            return 0
        }

        var eventCount = 0
        var weekStart = cal.dateInterval(of: .weekOfYear, for: rangeStart)?.start ?? rangeStart

        while weekStart <= rangeEnd {
            let weekDays = cal.daysWithSameWeekOfYear(as: weekStart).filter { day in
                day >= rangeStart && day <= rangeEnd
            }
            guard !weekDays.isEmpty else {
                guard let nextWeek = cal.date(byAdding: .weekOfYear, value: 1, to: weekStart) else { break }
                weekStart = nextWeek
                continue
            }
            let dayCount = Int.random(in: min(2, weekDays.count)...min(4, weekDays.count))
            let daysToSeed = weekDays.shuffled().prefix(dayCount)

            for day in daysToSeed {
                let eventsForDay = Int.random(in: 1...4)
                for index in 1...eventsForDay {
                    let event = EKEvent(eventStore: eventStore)
                    event.calendar = calendar
                    event.title = "\(titlePrefix) Event \(shortDate(day)) #\(index)"

                    if Int.random(in: 0..<5) == 0 {
                        event.isAllDay = true
                        event.startDate = day
                        event.endDate = cal.date(byAdding: .day, value: 1, to: day) ?? day.addingTimeInterval(86400)
                    } else {
                        let startHour = Int.random(in: 8...19)
                        let startMinute = [0, 15, 30, 45].randomElement() ?? 0
                        let durationMinutes = [30, 45, 60, 90, 120].randomElement() ?? 60
                        var startComponents = cal.dateComponents([.year, .month, .day], from: day)
                        startComponents.hour = startHour
                        startComponents.minute = startMinute
                        guard let startDate = cal.date(from: startComponents) else { continue }
                        event.startDate = startDate
                        event.endDate = startDate.addingTimeInterval(TimeInterval(durationMinutes * 60))
                    }

                    if Int.random(in: 0..<3) == 0 {
                        event.notes = "Debug seed notes for \(shortDate(day))."
                    }

                    try eventStore.save(event, span: .thisEvent, commit: false)
                    eventCount += 1
                }
            }

            guard let nextWeek = cal.date(byAdding: .weekOfYear, value: 1, to: weekStart) else { break }
            weekStart = nextWeek
        }

        try eventStore.commit()
        return eventCount
    }

    // MARK: - Reminders

    // swiftlint:disable:next function_body_length
    private static func seedReminders(using eventStore: EKEventStore,
                                      calendar: EKCalendar) throws -> Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())

        struct ReminderTemplate {
            let title: String
            let priority: Int
            let start: DateComponents?
            let due: DateComponents?
            let notes: String?
            let recurrence: EKRecurrenceRule?
            let isCompleted: Bool
            let completionDate: Date?
        }

        func dayComponents(_ date: Date, hour: Int? = nil, minute: Int? = nil) -> DateComponents {
            var components = cal.dateComponents([.year, .month, .day], from: date)
            if let hour { components.hour = hour; components.minute = minute ?? 0 }
            return components
        }

        func dateByAdding(days: Int, to date: Date = today) -> Date {
            cal.date(byAdding: .day, value: days, to: date) ?? date
        }

        let templates: [ReminderTemplate] = [
            ReminderTemplate(
                title: "\(titlePrefix) Due today w/ time",
                priority: 1,
                start: dayComponents(today, hour: 14, minute: 0),
                due: dayComponents(today, hour: 15, minute: 30),
                notes: nil, recurrence: nil, isCompleted: false, completionDate: nil
            ),
            ReminderTemplate(
                title: "\(titlePrefix) Due tomorrow",
                priority: 5,
                start: nil,
                due: dayComponents(dateByAdding(days: 1)),
                notes: nil, recurrence: nil, isCompleted: false, completionDate: nil
            ),
            ReminderTemplate(
                title: "\(titlePrefix) Due in 3 days",
                priority: 9,
                start: nil,
                due: dayComponents(dateByAdding(days: 3)),
                notes: nil, recurrence: nil, isCompleted: false, completionDate: nil
            ),
            ReminderTemplate(
                title: "\(titlePrefix) Overdue",
                priority: 1,
                start: nil,
                due: dayComponents(dateByAdding(days: -5)),
                notes: nil, recurrence: nil, isCompleted: false, completionDate: nil
            ),
            ReminderTemplate(
                title: "\(titlePrefix) Time range today",
                priority: 5,
                start: dayComponents(today, hour: 10, minute: 0),
                due: dayComponents(today, hour: 11, minute: 30),
                notes: nil, recurrence: nil, isCompleted: false, completionDate: nil
            ),
            ReminderTemplate(
                title: "\(titlePrefix) Start only today",
                priority: 9,
                start: dayComponents(today, hour: 16, minute: 0),
                due: nil,
                notes: nil, recurrence: nil, isCompleted: false, completionDate: nil
            ),
            ReminderTemplate(
                title: "\(titlePrefix) Title only",
                priority: 0,
                start: nil,
                due: nil,
                notes: nil, recurrence: nil, isCompleted: false, completionDate: nil
            ),
            ReminderTemplate(
                title: "\(titlePrefix) With notes",
                priority: 5,
                start: nil,
                due: dayComponents(dateByAdding(days: 7)),
                notes: "Debug reminder with notes for testing.",
                recurrence: nil, isCompleted: false, completionDate: nil
            ),
            ReminderTemplate(
                title: "\(titlePrefix) Weekly recurring",
                priority: 9,
                start: nil,
                due: dayComponents(today, hour: 9, minute: 0),
                notes: nil,
                recurrence: EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: nil),
                isCompleted: false, completionDate: nil
            ),
            ReminderTemplate(
                title: "\(titlePrefix) Far future",
                priority: 0,
                start: nil,
                due: dayComponents(dateByAdding(days: 25)),
                notes: nil, recurrence: nil, isCompleted: false, completionDate: nil
            ),
            ReminderTemplate(
                title: "\(titlePrefix) Completed",
                priority: 5,
                start: nil,
                due: dayComponents(dateByAdding(days: -1)),
                notes: nil, recurrence: nil, isCompleted: true,
                completionDate: dateByAdding(days: -1, to: today).addingTimeInterval(3600 * 10)
            ),
            ReminderTemplate(
                title: "\(titlePrefix) All-day due",
                priority: 1,
                start: nil,
                due: dayComponents(dateByAdding(days: 2)),
                notes: nil, recurrence: nil, isCompleted: false, completionDate: nil
            ),
        ]

        for template in templates {
            let reminder = EKReminder(eventStore: eventStore)
            reminder.calendar = calendar
            reminder.title = template.title
            reminder.priority = template.priority
            reminder.startDateComponents = template.start
            reminder.dueDateComponents = template.due
            reminder.notes = template.notes
            reminder.recurrenceRules = template.recurrence.map { [$0] }
            reminder.isCompleted = template.isCompleted
            reminder.completionDate = template.completionDate
            try eventStore.save(reminder, commit: false)
        }

        try eventStore.commit()
        return templates.count
    }

    private static func shortDate(_ date: Date) -> String {
        DateFormatter(format: "M/d").string(from: date)
    }
}

struct DebugSeedTestDataButton: View {

    @Dependency(\.eventKitManager) private var eventKitManager
    @EnvironmentObject private var calendarItemListViewModel: CalendarItemListViewModel

    @State private var isSeeding = false
    @State private var statusMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button("Add Test Events & Reminders") {
                seedTestData()
            }
            .disabled(isSeeding)

            if isSeeding {
                ProgressView()
            } else if let statusMessage {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func seedTestData() {
        isSeeding = true
        statusMessage = nil
        Task {
            do {
                let result = try await DebugTestDataSeeder.seed(using: eventKitManager.eventStore)
                await MainActor.run {
                    statusMessage = "Added \(result.events) events and \(result.reminders) reminders."
                    calendarItemListViewModel.updateData()
                    isSeeding = false
                }
            } catch {
                await MainActor.run {
                    statusMessage = error.localizedDescription
                    isSeeding = false
                }
            }
        }
    }
}
#endif
