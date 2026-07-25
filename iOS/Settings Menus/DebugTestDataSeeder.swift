//
//  DebugTestDataSeeder.swift
//  TimeDraw
//

#if DEBUG
// swiftlint:disable file_length
import Dependencies
import AppCore
import DesignToken
import EventKit
import EventManagement
import SwiftUI

enum DebugTestDataSeeder {

    static let titlePrefix = "[Debug]"
    static let workCalendarTitle = "Work"
    static let personalCalendarTitle = "Personal"

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

    struct SeedResult {
        let events: Int
        let reminders: Int
        let calendarIds: [String]
    }

    static func seed(using eventStore: EKEventStore) async throws -> SeedResult {
        try await requestAccess(using: eventStore)

        let workCalendar = try findOrCreateEventCalendar(
            titled: workCalendarTitle,
            color: CGColor(red: 0.20, green: 0.45, blue: 0.85, alpha: 1),
            eventStore: eventStore
        )
        let personalCalendar = try findOrCreateEventCalendar(
            titled: personalCalendarTitle,
            color: CGColor(red: 0.20, green: 0.70, blue: 0.45, alpha: 1),
            eventStore: eventStore
        )
        guard let reminderCalendar = calendar(for: .reminder, eventStore: eventStore) else {
            throw SeederError.missingCalendar
        }

        let eventCount = try seedEvents(
            using: eventStore,
            workCalendar: workCalendar,
            personalCalendar: personalCalendar
        )
        let reminderCount = try seedReminders(using: eventStore, calendar: reminderCalendar)
        return SeedResult(
            events: eventCount,
            reminders: reminderCount,
            calendarIds: [
                workCalendar.calendarIdentifier,
                personalCalendar.calendarIdentifier,
                reminderCalendar.calendarIdentifier,
            ]
        )
    }

    // MARK: - Authorization

    private static func requestAccess(using eventStore: EKEventStore) async throws {
        guard try await eventStore.requestFullAccessToEvents(),
              try await eventStore.requestFullAccessToReminders() else {
            throw SeederError.accessDenied
        }
    }

    // MARK: - Calendars

    private static func preferredCalendarSource(in eventStore: EKEventStore) -> EKSource? {
        eventStore.sources.first(where: { $0.sourceType == .local })
            ?? eventStore.defaultCalendarForNewEvents?.source
            ?? eventStore.sources.first(where: { $0.sourceType == .calDAV })
            ?? eventStore.sources.first
    }

    private static func findOrCreateEventCalendar(
        titled title: String,
        color: CGColor,
        eventStore: EKEventStore
    ) throws -> EKCalendar {
        if let existing = eventStore.calendars(for: .event).first(where: {
            $0.title.caseInsensitiveCompare(title) == .orderedSame
        }) {
            return existing
        }

        let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
        newCalendar.title = title
        newCalendar.cgColor = color
        newCalendar.source = preferredCalendarSource(in: eventStore)
        try eventStore.saveCalendar(newCalendar, commit: true)
        return newCalendar
    }

    private static func calendar(for entityType: EKEntityType, eventStore: EKEventStore) -> EKCalendar? {
        let appName = EventKitManager.appName
        let calendars = eventStore.calendars(for: entityType)
        if let existing = calendars.first(where: { $0.title == appName }) {
            return existing
        }

        let newCalendar = EKCalendar(for: entityType, eventStore: eventStore)
        newCalendar.title = appName
        newCalendar.source = preferredCalendarSource(in: eventStore)
        newCalendar.cgColor = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
        do {
            try eventStore.saveCalendar(newCalendar, commit: true)
            return newCalendar
        } catch {
            return entityType == .event
                ? eventStore.defaultCalendarForNewEvents
                : eventStore.defaultCalendarForNewReminders()
        }
    }

    // MARK: - Events

    private struct TimedEventTemplate {
        let title: String
        let hour: Int
        let minute: Int
        let durationMinutes: Int
        let notes: String?
        let isPersonal: Bool

        init(
            _ title: String,
            hour: Int,
            minute: Int = 0,
            durationMinutes: Int,
            notes: String? = nil,
            isPersonal: Bool = false
        ) {
            self.title = title
            self.hour = hour
            self.minute = minute
            self.durationMinutes = durationMinutes
            self.notes = notes
            self.isPersonal = isPersonal
        }
    }

    private static func seedEvents(
        using eventStore: EKEventStore,
        workCalendar: EKCalendar,
        personalCalendar: EKCalendar
    ) throws -> Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        guard let firstMonday = mondayStartingWorkWeek(containing: today, calendar: cal) else {
            return 0
        }

        var eventCount = 0

        for weekOffset in 0..<3 {
            guard let weekMonday = cal.date(byAdding: .weekOfYear, value: weekOffset, to: firstMonday) else {
                continue
            }

            for weekdayOffset in 0..<5 {
                guard let day = cal.date(byAdding: .day, value: weekdayOffset, to: weekMonday) else {
                    continue
                }
                for template in workdayTemplates(weekdayOffset: weekdayOffset, weekOffset: weekOffset) {
                    try saveTimedEvent(
                        template,
                        on: day,
                        workCalendar: workCalendar,
                        personalCalendar: personalCalendar,
                        eventStore: eventStore
                    )
                    eventCount += 1
                }
            }

            for weekendOffset in 5...6 {
                guard let day = cal.date(byAdding: .day, value: weekendOffset, to: weekMonday) else {
                    continue
                }
                for template in weekendTemplates(isSaturday: weekendOffset == 5, weekOffset: weekOffset) {
                    try saveTimedEvent(
                        template,
                        on: day,
                        workCalendar: workCalendar,
                        personalCalendar: personalCalendar,
                        eventStore: eventStore
                    )
                    eventCount += 1
                }

                if weekOffset == 1, weekendOffset == 5 {
                    try saveAllDayEvent(
                        title: "Beach Day",
                        on: day,
                        calendar: personalCalendar,
                        eventStore: eventStore,
                        notes: "Pack sunscreen and chairs."
                    )
                    eventCount += 1
                }
            }
        }

        try eventStore.commit()
        return eventCount
    }

    /// Monday of the week containing `date` (Mon–Sun work-week framing).
    private static func mondayStartingWorkWeek(containing date: Date, calendar: Calendar) -> Date? {
        let start = calendar.startOfDay(for: date)
        let weekday = calendar.component(.weekday, from: start) // 1 = Sunday … 7 = Saturday
        let daysFromMonday = (weekday + 5) % 7
        return calendar.date(byAdding: .day, value: -daysFromMonday, to: start)
    }

    private static func workdayTemplates(weekdayOffset: Int, weekOffset: Int) -> [TimedEventTemplate] {
        let teammates = ["Priya", "Jordan", "Sam", "Alex", "Riley"]
        let partner = teammates[weekOffset % teammates.count]

        var templates: [TimedEventTemplate] = [
            TimedEventTemplate("Daily Standup", hour: 9, durationMinutes: 15,
                               notes: "Platform team sync."),
        ]

        switch weekdayOffset {
        case 0: // Monday
            templates += [
                TimedEventTemplate("Sprint Planning", hour: 10, durationMinutes: 60),
                TimedEventTemplate("Focus: Calendar polish", hour: 11, minute: 30, durationMinutes: 60),
                TimedEventTemplate("Lunch", hour: 12, minute: 30, durationMinutes: 30),
                TimedEventTemplate("1:1 with \(partner)", hour: 14, durationMinutes: 30),
                TimedEventTemplate("Deep Work", hour: 15, durationMinutes: 90),
            ]
        case 1: // Tuesday
            templates += [
                TimedEventTemplate("Design Review — Event Input", hour: 10, durationMinutes: 45),
                TimedEventTemplate("Pair with \(partner)", hour: 11, durationMinutes: 90),
                TimedEventTemplate("Lunch with Maya", hour: 12, minute: 45, durationMinutes: 45,
                                   isPersonal: weekOffset == 1),
                TimedEventTemplate("Call with Acme", hour: 14, minute: 30, durationMinutes: 45,
                                   notes: "Walk through the latest build."),
                TimedEventTemplate("Inbox Zero", hour: 16, durationMinutes: 30),
            ]
        case 2: // Wednesday
            templates += [
                TimedEventTemplate("Midweek Sync", hour: 10, durationMinutes: 30),
                TimedEventTemplate("Write release notes", hour: 11, durationMinutes: 60),
                TimedEventTemplate("Lunch Walk", hour: 12, minute: 30, durationMinutes: 30,
                                   isPersonal: true),
                TimedEventTemplate("Interview — iOS Engineer", hour: 13, minute: 30, durationMinutes: 90),
                TimedEventTemplate("Code Review Block", hour: 15, minute: 30, durationMinutes: 60),
            ]
        case 3: // Thursday
            templates += [
                TimedEventTemplate("Demo Prep", hour: 9, minute: 30, durationMinutes: 30),
                TimedEventTemplate("Sync with Design", hour: 10, minute: 30, durationMinutes: 45),
                TimedEventTemplate("Lunch", hour: 12, durationMinutes: 45),
                TimedEventTemplate("Architecture Review", hour: 13, minute: 30, durationMinutes: 60),
                TimedEventTemplate("Ship Checklist", hour: 15, durationMinutes: 45),
            ]
        default: // Friday
            templates += [
                TimedEventTemplate("Team Demo", hour: 10, durationMinutes: 45),
                TimedEventTemplate("Sprint Retro", hour: 11, durationMinutes: 45),
                TimedEventTemplate("Team Lunch", hour: 12, minute: 15, durationMinutes: 60),
                TimedEventTemplate("Next-week Planning", hour: 14, durationMinutes: 60),
                TimedEventTemplate("Friday Focus", hour: 15, minute: 30, durationMinutes: 60),
            ]
        }

        if weekdayOffset == 1 || weekdayOffset == 3 {
            templates.append(
                TimedEventTemplate("Gym", hour: 18, durationMinutes: 60, isPersonal: true)
            )
        }
        if weekOffset == 0, weekdayOffset == 4 {
            templates.append(
                TimedEventTemplate("Dinner with Friends", hour: 19, durationMinutes: 90,
                                   isPersonal: true)
            )
        } else if weekOffset == 1, weekdayOffset == 2 {
            templates.append(
                TimedEventTemplate("Coffee with Chris", hour: 17, minute: 30, durationMinutes: 45,
                                   isPersonal: true)
            )
        }

        return templates
    }

    private static func weekendTemplates(isSaturday: Bool, weekOffset: Int) -> [TimedEventTemplate] {
        if isSaturday {
            var templates: [TimedEventTemplate] = [
                TimedEventTemplate("Morning Run", hour: 8, durationMinutes: 45,
                                   isPersonal: true),
                TimedEventTemplate("Brunch at Riverview", hour: 10, minute: 30, durationMinutes: 90,
                                   isPersonal: true),
                TimedEventTemplate("Errands", hour: 14, durationMinutes: 90,
                                   notes: "Groceries, dry cleaning, hardware store.",
                                   isPersonal: true),
            ]
            if weekOffset == 2 {
                templates.append(
                    TimedEventTemplate("Movie Night", hour: 19, durationMinutes: 150,
                                       isPersonal: true)
                )
            } else if weekOffset == 0 {
                templates.append(
                    TimedEventTemplate("Birthday Party — Taylor", hour: 18, durationMinutes: 180,
                                       isPersonal: true)
                )
            }
            return templates
        }

        var templates: [TimedEventTemplate] = [
            TimedEventTemplate("Meal Prep", hour: 11, durationMinutes: 90,
                               isPersonal: true),
            TimedEventTemplate("Call Mom", hour: 15, durationMinutes: 45,
                               isPersonal: true),
            TimedEventTemplate("Wind-down Read", hour: 19, durationMinutes: 60,
                               isPersonal: true),
        ]
        if weekOffset == 0 {
            templates.insert(
                TimedEventTemplate("Hike — Ridge Trail", hour: 8, minute: 30, durationMinutes: 120,
                                   isPersonal: true),
                at: 0
            )
        } else if weekOffset == 1 {
            templates.insert(
                TimedEventTemplate("Farmers Market", hour: 9, durationMinutes: 75,
                                   isPersonal: true),
                at: 0
            )
        }
        return templates
    }

    private static func saveTimedEvent(
        _ template: TimedEventTemplate,
        on day: Date,
        workCalendar: EKCalendar,
        personalCalendar: EKCalendar,
        eventStore: EKEventStore
    ) throws {
        let cal = Calendar.current
        var components = cal.dateComponents([.year, .month, .day], from: day)
        components.hour = template.hour
        components.minute = template.minute
        guard let startDate = cal.date(from: components) else { return }

        let event = EKEvent(eventStore: eventStore)
        event.calendar = template.isPersonal ? personalCalendar : workCalendar
        event.title = template.title
        event.startDate = startDate
        event.endDate = startDate.addingTimeInterval(TimeInterval(template.durationMinutes * 60))
        event.notes = template.notes
        try eventStore.save(event, span: .thisEvent, commit: false)
    }

    private static func saveAllDayEvent(
        title: String,
        on day: Date,
        calendar: EKCalendar,
        eventStore: EKEventStore,
        notes: String? = nil
    ) throws {
        let cal = Calendar.current
        let event = EKEvent(eventStore: eventStore)
        event.calendar = calendar
        event.title = title
        event.isAllDay = true
        event.startDate = day
        event.endDate = cal.date(byAdding: .day, value: 1, to: day) ?? day.addingTimeInterval(86400)
        event.notes = notes
        try eventStore.save(event, span: .thisEvent, commit: false)
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
}

struct DebugSeedTestDataButton: View {

    @Dependency(\.eventKitManager) private var eventKitManager
    @EnvironmentObject private var calendarItemListViewModel: CalendarListViewModel
    @AppStorage(AppStorageKey.userSelectedCalendars) private var userSelectedCalendars: Data?

    @State private var isSeeding = false
    @State private var statusMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button("Add Test Events & Reminders") {
                seedTestData()
            }
            .font(.app(.body))
            .disabled(isSeeding)

            if isSeeding {
                ProgressView()
            } else if let statusMessage {
                Text(statusMessage)
                    .font(.app(.fine))
                    .foregroundStyle(Colors.secondaryText)
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
                    ensureCalendarsSelected(result.calendarIds)
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

    private func ensureCalendarsSelected(_ calendarIds: [String]) {
        var selected = userSelectedCalendars.loadCalendarIds()
        guard !selected.isEmpty else { return }
        var didChange = false
        for id in calendarIds where !selected.contains(id) {
            selected.append(id)
            didChange = true
        }
        if didChange {
            userSelectedCalendars = selected.archiveCalendars()
        }
    }
}
#endif
