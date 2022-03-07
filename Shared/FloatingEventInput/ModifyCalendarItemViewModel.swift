//
//  ModifyCalendarItemViewModel.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/21/22.
//

import Foundation
import EventKit
import SwiftUI

/// Used for creating an EKCalendarItem Event/Reminder with the Floating Input Views
/// 
class ModifyCalendarItemViewModel: ObservableObject {
    
    // Utility vars
    let weekdayFormatter = DateFormatter(format: "E")
    var daysOfTheWeek = [String]()
    
    /// Used to determine if the event is being created or edited
    private(set) var editMode: Bool = false
    /// Used to display the toast for when new things are mode
    @Published var displayToast: Bool = false
    @Published var toastMessage: String = ""
    
    // MARK: - New EKCalendarItem Data
    
    var calendarItem: EKCalendarItem?
    // New Event/Reminder Data
    @Published var newItemTitle: String = ""
    /// Convenience binding to pass a published variable as
    public var newItemTitleBinding: Binding<String> {  Binding<String>(get: { self.newItemTitle }, set: { self.newItemTitle = $0 }) }
    // For the "Add Time" feature
    @Published var newItemStartTime: DateComponents?
    @Published var newItemEndTime: DateComponents?
    // For the "Add Date/Time" feature
    @Published var newItemStartDate: DateComponents?
    @Published var newItemEndDate: DateComponents?
    
    // MARK: - Recurrence Rule vars
    
    private var recurrenceRule: EKRecurrenceRule?
    private var recurrenceEnd: EKRecurrenceEnd?
    @Published var endRecurrenceDate: DateComponents?
    @Published var endRecurrenceTime: DateComponents?
    @Published var numberOfOccurences: Int?
    @Published var isRecurrenceUsingOccurences: Bool = false
    @Published var frequencyDayValueInt: Int?
    @Published var frequencyWeekdayValue: EKWeekday = .monday
    @Published var frequencyMonthDate: Int?
    @Published var selectedRule: EKRecurrenceFrequency = .weekly
    
    // MARK: - Display State vars
    
    @Published var isAddEventTextFieldFocused: Bool = false
    @Published var isDisplayingOptions: Bool = false
    @Published var isDateTimePickerOpen: Bool = false
    @Published var isRecurrencePickerOpen: Bool = false
    public var isFocused: Bool { self.isDateTimePickerOpen || self.isRecurrencePickerOpen }
    
    init() {
        if let month = Calendar.current.dateComponents([.month], from: Date()).month {
            self.frequencyMonthDate = month - 1
        }
        let daysInThisWeek = Calendar.current.daysWithSameWeekOfYear(as: Date())
        self.daysOfTheWeek = daysInThisWeek.compactMap { self.weekdayFormatter.string(from: $0) }
        self.editMode = false
    }
    
    @MainActor func open(event: EKEvent) {
        self.reset()
        self.editMode = true
        self.isAddEventTextFieldFocused = true
        self.calendarItem = event
        self.newItemTitle = event.title
        if let startDate = event.startDate {
            self.isDateTimePickerOpen = true
            self.newItemStartTime = startDate.get(.hour, .minute, .second)
            self.newItemStartDate = startDate.get(.month, .day, .year)
        }
        if let endDate = event.endDate {
            self.isDateTimePickerOpen = true
            self.newItemEndTime = endDate.get(.hour, .minute, .second)
            self.newItemEndDate = endDate.get(.month, .day, .year)
        }
        self.extractRecurrenceRules(for: event)
    }
    
    @MainActor func open(reminder: EKReminder) {
        self.reset()
        self.editMode = true
        self.isAddEventTextFieldFocused = true
        self.calendarItem = reminder
        self.newItemTitle = reminder.title
        if let startDate = reminder.startDateComponents?.date {
            self.isDateTimePickerOpen = true
            self.newItemStartTime = startDate.get(.hour, .minute, .second)
            self.newItemStartDate = startDate.get(.month, .day, .year)
        }
        if let endDate = reminder.dueDateComponents?.date {
            self.isDateTimePickerOpen = true
            self.newItemEndTime = endDate.get(.hour, .minute, .second)
            self.newItemEndDate = endDate.get(.month, .day, .year)
        }
        self.extractRecurrenceRules(for: reminder)
    }
    
    func addTimeToEvent() {
        withAnimation {
            self.isDateTimePickerOpen = true
        }
    }
    
    func removeTimeFromEvent() {
        withAnimation {
            self.clearTimeInput()
        }
    }
    
    // MARK: - Recurrence
    
    private func extractRecurrenceRules(for item: EKCalendarItem) {
        if let recurrenceRule = item.recurrenceRules?.first {
            self.isRecurrencePickerOpen = true
            self.recurrenceRule = recurrenceRule
            self.recurrenceEnd = recurrenceRule.recurrenceEnd
            if let recurrenceEndDate = recurrenceRule.recurrenceEnd?.endDate {
                self.endRecurrenceDate = recurrenceEndDate.get(.month, .day, .year)
                self.endRecurrenceTime = recurrenceEndDate.get(.hour, .minute, .second)
            }
            // FIXME
            self.numberOfOccurences = nil
            self.frequencyDayValueInt = recurrenceRule.daysOfTheWeek?.first?.dayOfTheWeek.rawValue
            self.frequencyMonthDate = recurrenceRule.daysOfTheMonth?.first?.intValue
        }
    }
    
    func openRecurrencePicker() {
        withAnimation {
            self.isRecurrencePickerOpen = true
        }
    }
    
    func removeRecurrenceFromEvent() {
        withAnimation {
            self.clearRecurrence()
        }
    }
    
    private func handleRecurrence(for item: EKCalendarItem) {
        self.setRecurrenceRule()
        if self.isRecurrencePickerOpen,
           let recurrenceRule = recurrenceRule {
            item.recurrenceRules = nil
            item.addRecurrenceRule(recurrenceRule)
        } else if let existingRule = item.recurrenceRules?.first {
            item.removeRecurrenceRule(existingRule)
        }
    }
    
    private func setRecurrenceRule() {
        if let recurrenceEnd = self.endRecurrenceDate,
           let recurrenceEndDate = Calendar.current.date(from: recurrenceEnd) {
            self.recurrenceEnd = EKRecurrenceEnd(end: recurrenceEndDate)
        } else if let numberOfOccurences = numberOfOccurences {
            self.recurrenceEnd = EKRecurrenceEnd(occurrenceCount: numberOfOccurences)
        }
        let interval = self.frequencyDayValueInt ?? 1
        switch self.selectedRule {
        case .daily:
            self.recurrenceRule = EKRecurrenceRule(recurrenceWith: selectedRule, interval: interval, end: self.recurrenceEnd)
        case .weekly:
            self.recurrenceRule = EKRecurrenceRule(recurrenceWith: self.selectedRule, interval: interval, daysOfTheWeek: EKWeekday.getSelectedWeekDays(for: self.frequencyWeekdayValue), daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: self.recurrenceEnd)
        case .monthly:
            if let frequencyValue = self.frequencyDayValueInt {
                let recurrenceDay = frequencyValue as NSNumber
                self.recurrenceRule = EKRecurrenceRule(recurrenceWith: self.selectedRule, interval: 1, daysOfTheWeek: nil, daysOfTheMonth: [recurrenceDay], monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: self.recurrenceEnd)
            }
        case .yearly:
            self.recurrenceRule = EKRecurrenceRule(recurrenceWith: self.selectedRule, interval: 1, daysOfTheWeek: nil, daysOfTheMonth: [NSNumber(nonretainedObject: self.frequencyDayValueInt)], monthsOfTheYear: (1...12).compactMap { NSNumber(value: $0) }, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: self.recurrenceEnd)
        @unknown default:
            print(self.selectedRule)
        }
    }
    
    func setSuggestedEndRecurrenceDate() {
        if self.endRecurrenceDate == nil {
            var suggestedEndDate: Date
            switch self.selectedRule {
            case .daily: suggestedEndDate = Date().addingTimeInterval(60 * 60 * 24 * 31)
            case .weekly: suggestedEndDate = Date().addingTimeInterval(60 * 60 * 24 * 7 * 4)
            case .monthly: suggestedEndDate = Date().addingTimeInterval(60 * 60 * 24 * 30 * 6)
            case .yearly: suggestedEndDate = Date().addingTimeInterval(60 * 60 * 24 * 366 * 2)
            default: suggestedEndDate = Date().addingTimeInterval(60 * 60 * 24 * 5)
            }
            self.endRecurrenceDate = Calendar.current.dateComponents([.day, .month, .year], from: suggestedEndDate)
            self.endRecurrenceTime = Calendar.current.dateComponents([.hour, .minute, .second], from: suggestedEndDate)
            self.numberOfOccurences = nil
        }
    }
    
    // MARK: - Delete
    
    @MainActor func reset() {
        withAnimation {
            self.editMode = false
            self.calendarItem = nil
            self.newItemTitle = ""
            self.isAddEventTextFieldFocused = false
            self.isDisplayingOptions = false
            
            self.clearTimeInput()
            self.clearRecurrence()
        }
        EventListViewModel.shared.updateData()
    }
    
    private func clearTimeInput() {
        self.isDateTimePickerOpen = false
        self.newItemStartTime = nil
        self.newItemEndTime = nil
        self.newItemStartDate = nil
        self.newItemEndDate = nil
    }
    
    private func clearRecurrence() {
        self.isRecurrencePickerOpen = false
        self.recurrenceRule = nil
        self.recurrenceEnd = nil
        self.endRecurrenceDate = nil
        self.endRecurrenceTime = nil
        self.numberOfOccurences = nil
        self.frequencyDayValueInt = nil
        self.frequencyMonthDate = nil
    }
    
    @MainActor func delete() {
        if let reminder = self.calendarItem as? EKReminder {
            do {
                try EventKitManager.shared.eventStore.deleteReminder(identifier: reminder.calendarItemIdentifier)
            } catch  {
                print(error)
            }
            self.save(reminder: reminder, "Reminder Deleted")
        }
        if let event = self.calendarItem as? EKEvent {
            do {
                try EventKitManager.shared.eventStore.deleteEvent(identifier: event.eventIdentifier, span: .futureEvents)
            } catch  {
                print(error)
            }
            self.save(event: event, "Event Deleted")
        }
        self.reset()
    }
    
    // MARK: - Create
    
    /// Create an EKCalendarItem for the given information OR the currently displayed EKCalendarItem will be saved
    @MainActor public func submitEventOrReminder() {
        Task {
            let startDateComponents = self.newItemStartDate
            let startTimeComponents = self.newItemStartTime
            let endTimeComponents = self.newItemEndTime
            let endDateComponents = self.newItemEndDate
            var mergedStartComponments: DateComponents = DateComponents()
            var mergedEndComponments: DateComponents = DateComponents()
            if startDateComponents != nil || startTimeComponents != nil {
                mergedStartComponments.year = startDateComponents?.year
                mergedStartComponments.month = startDateComponents?.month
                mergedStartComponments.day = startDateComponents?.day
                mergedStartComponments.hour = startTimeComponents?.hour
                mergedStartComponments.minute = startTimeComponents?.minute
                mergedStartComponments.second = startTimeComponents?.second
            }
            if endDateComponents != nil || endTimeComponents != nil {
                mergedEndComponments.year = endDateComponents?.year
                mergedEndComponments.month = endDateComponents?.month
                mergedEndComponments.day = endDateComponents?.day
                mergedEndComponments.hour = endTimeComponents?.hour
                mergedEndComponments.minute = endTimeComponents?.minute
                mergedEndComponments.second = endTimeComponents?.second
            }
            if self.newItemStartDate != nil,
               self.newItemEndDate != nil,
               let startDate = Calendar.current.date(from: mergedStartComponments),
               let endDate = Calendar.current.date(from: mergedEndComponments),
               let event = self.calendarItem as? EKEvent {
                self.saveEvent(event, start: startDate, end: endDate)
            } else {
                let start = self.newItemStartDate != nil ? mergedStartComponments : nil
                let end = self.newItemEndDate != nil ? mergedEndComponments : nil
                if let reminder = self.calendarItem as? EKReminder {
                    self.saveReminder(reminder: reminder, start: start, end: end)
                } else {
                    await self.createReminder(start: start, end: end)
                }
            }
        }
    }
    
    /// If there is a Start and End date make an Event from the given info, or save an existing Event with any modified info
    @MainActor private func saveEvent(_ event: EKEvent, start startDate: Date, end endDate: Date) {
        Task {
            event.title = self.newItemTitle
            event.startDate = startDate
            event.endDate = endDate
            self.handleRecurrence(for: event)
            self.save(event: event, "Event Saved")
        }
    }
    
    @MainActor private func createEvent(start startDate: Date, end endDate: Date) async {
        do {
            let newEvent = try await EventKitManager.shared.createEvent(self.newItemTitle, startDate: startDate, endDate: endDate)
            self.handleRecurrence(for: newEvent)
            self.save(event: newEvent, "Event Created")
        } catch let error as NSError {
            print("Error: failed to save event with error : \(error)")
        }
    }
    
    @MainActor private func save(event: EKEvent, _ message: String) {
        do {
            try EventKitManager.shared.eventStore.save(event, span: .thisEvent)
        } catch  {
            print(error)
        }
        self.displayToast(message)
        self.reset()
    }
    
    /// If there is a Start and End date make an Reminder from the given info, or save an existing Reminder with any modified info
    @MainActor private func saveReminder(reminder: EKReminder, start startComponents: DateComponents?, end endComponents: DateComponents?) {
        Task {
            reminder.title = self.newItemTitle
            reminder.startDateComponents = startComponents
            reminder.dueDateComponents = endComponents
            self.handleRecurrence(for: reminder)
            self.save(reminder: reminder, "Reminder Created")
        }
    }
    
    @MainActor private func createReminder(start startComponents: DateComponents?, end endComponents: DateComponents?) async {
        do {
            let newReminder = try await EventKitManager.shared.createReminder(self.newItemTitle, startDate: startComponents, dueDate: endComponents)
            self.handleRecurrence(for: newReminder)
            self.save(reminder: newReminder, "Reminder Saved")
        } catch let error as NSError {
            print("Error: failed to save reminder with error : \(error)")
        }
    }
    
    @MainActor private func save(reminder: EKReminder, _ message: String) {
        try? EventKitManager.shared.eventStore.save(reminder, commit: true)
        self.displayToast(message)
        self.reset()
    }
    
    /// Update the Toast notification to alert the user
    @MainActor private func displayToast(_ message: String) {
        self.toastMessage = message
        self.displayToast = true
    }
    
    // MARK: - Utility
    
    func getRecentEmojis() -> [String] {
        guard let prefs = UserDefaults(suiteName: "com.apple.EmojiPreferences"),
              let defaults = prefs.dictionary(forKey: "EMFDefaultsKey"),
              let recents = defaults["EMFRecentsKey"] as? [String] else {
                  // No Recent Emojis
                  return ["No Recent Emojis"]
              }
        return recents
    }
}
