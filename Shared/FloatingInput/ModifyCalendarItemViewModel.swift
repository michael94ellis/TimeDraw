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
    @Published var notesInput: String = ""
    
    // MARK: - Recurrence Rule vars
    
    @Published var endRecurrenceDate: DateComponents?
    @Published var endRecurrenceTime: DateComponents?
    private var recurrenceRule: EKRecurrenceRule?
    private var recurrenceEnd: EKRecurrenceEnd?
    @Published var selectedRule: EKRecurrenceFrequency = .weekly
    
    @Published var isRecurrenceUsingOccurences: Bool = false
    @Published var numberOfOccurences: Int?
    @Published var dayFrequencyText: String = ""
    @Published var frequencyDayValueInt: Int?
    @Published var selectedMonthDays: [Int] = []
    @Published var frequencyWeekdayValues: [EKWeekday] = []
    @Published var frequencyMonthDate: Int?
    
    // MARK: - Display State vars
    
    @Published var isAddEventTextFieldFocused: Bool = false
    @Published var isDisplayingOptions: Bool = false
    @Published var isDateTimePickerOpen: Bool = false
    @Published var isNotesInputOpen: Bool = false
    @Published var isRecurrencePickerOpen: Bool = false
    public var isFocused: Bool { self.isDateTimePickerOpen || self.isRecurrencePickerOpen }
    
    init() {
        self.frequencyMonthDate = Date().get(.month) - 1
        let daysInThisWeek = Calendar.current.daysWithSameWeekOfYear(as: Date())
        self.editMode = false
        self.daysOfTheWeek = daysInThisWeek.compactMap { self.weekdayFormatter.string(from: $0) }
    }
    
    @MainActor func open(event: EKEvent) {
        self.reset()
        self.editMode = true
        self.isAddEventTextFieldFocused = true
        self.calendarItem = event
        self.newItemTitle = event.title
        if event.hasNotes {
            self.notesInput = event.notes ?? ""
            self.isNotesInputOpen = true
        }
        if let startDate = event.startDate {
            self.isDateTimePickerOpen = true
            self.newItemStartTime = startDate.get(.hour, .minute, .second)
            self.newItemStartDate = startDate.get(.month, .day, .year)
            self.extractRecurrenceRules(for: event, start: startDate)
        }
        if let endDate = event.endDate {
            self.isDateTimePickerOpen = true
            self.newItemEndTime = endDate.get(.hour, .minute, .second)
            self.newItemEndDate = endDate.get(.month, .day, .year)
        }
    }
    
    @MainActor func open(reminder: EKReminder) {
        self.reset()
        self.editMode = true
        self.isAddEventTextFieldFocused = true
        self.calendarItem = reminder
        self.newItemTitle = reminder.title
        if reminder.hasNotes {
            self.notesInput = reminder.notes ?? ""
            self.isNotesInputOpen = true
        }
        if let startDate = reminder.startDateComponents?.date {
            self.isDateTimePickerOpen = true
            self.newItemStartTime = startDate.get(.hour, .minute, .second)
            self.newItemStartDate = startDate.get(.month, .day, .year)
            self.extractRecurrenceRules(for: reminder, start: startDate)
        }
        if let endDate = reminder.dueDateComponents?.date {
            self.isDateTimePickerOpen = true
            self.newItemEndTime = endDate.get(.hour, .minute, .second)
            self.newItemEndDate = endDate.get(.month, .day, .year)
        }
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
    
    func addNotesToEvent() {
        withAnimation {
            self.isNotesInputOpen = true
        }
    }
    
    func removeNotesFromEvent() {
        withAnimation {
            self.clearNotesInput()
        }
    }
    
    // MARK: - Recurrence
    
    private func extractRecurrenceRules(for item: EKCalendarItem, start: Date) {
        if let recurrenceRule = item.recurrenceRules?.first {
            self.isRecurrencePickerOpen = true
            self.selectedRule = recurrenceRule.frequency
            self.recurrenceRule = recurrenceRule
            self.recurrenceEnd = recurrenceRule.recurrenceEnd
            if let recurrenceEndDate = recurrenceRule.recurrenceEnd?.endDate {
                self.endRecurrenceDate = recurrenceEndDate.get(.month, .day, .year)
                self.endRecurrenceTime = recurrenceEndDate.get(.hour, .minute, .second)
            }
            if let occurences = recurrenceRule.recurrenceEnd?.occurrenceCount {
                self.numberOfOccurences = occurences
                self.isRecurrenceUsingOccurences = true
            }
            switch recurrenceRule.frequency {
            case .daily:
                self.frequencyDayValueInt = recurrenceRule.interval
                self.dayFrequencyText = String(recurrenceRule.interval)
            case .weekly:
                if let selectedDays = recurrenceRule.daysOfTheWeek?.compactMap({ $0.dayOfTheWeek }) {
                    self.frequencyWeekdayValues = selectedDays
                }
            case .monthly:
                self.selectedMonthDays = (recurrenceRule.daysOfTheMonth ?? []) as? [Int] ?? []
            case .yearly:
                if let days = recurrenceRule.daysOfTheMonth {
                    self.selectedMonthDays = days as? [Int] ?? []
                    if let month = recurrenceRule.monthsOfTheYear?.first?.intValue {
                        self.frequencyMonthDate = month - 1
                    }
                } else {
                    let day = start.get(.day)
                    let month = start.get(.month)
                    self.selectedMonthDays = [day]
                    self.frequencyMonthDate = month - 1
                }
            default:
                break
            }
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
    
    // The implementation only supports a single recurrence rule. Adding a recurrence rule replaces the single recurrence rule
    private func handleRecurrence(for item: EKCalendarItem) {
        self.setRecurrenceRule()
        if let existingRule = item.recurrenceRules?.first {
            item.removeRecurrenceRule(existingRule)
        }
        if self.isRecurrencePickerOpen,
           let recurrenceRule = self.recurrenceRule {
            item.addRecurrenceRule(recurrenceRule)
        }
    }
    
    private func setRecurrenceRule() {
        // Optional recurrence end rule
        if let recurrenceEnd = self.endRecurrenceDate,
           let recurrenceEndDate = Calendar.current.date(from: recurrenceEnd) {
            self.recurrenceEnd = EKRecurrenceEnd(end: recurrenceEndDate)
        } else if let numberOfOccurences = numberOfOccurences {
            self.recurrenceEnd = EKRecurrenceEnd(occurrenceCount: numberOfOccurences)
        } else {
            self.recurrenceEnd = nil
        }
        switch self.selectedRule {
        case .daily:
            let interval = self.frequencyDayValueInt ?? 1
            self.recurrenceRule = EKRecurrenceRule(recurrenceWith: selectedRule, interval: interval, end: self.recurrenceEnd)
        case .weekly:
            let recurrenceDays = EKWeekday.getSelectedWeekDays(for: self.frequencyWeekdayValues)
            self.recurrenceRule = EKRecurrenceRule(recurrenceWith: self.selectedRule, interval: 1, daysOfTheWeek: recurrenceDays, daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: self.recurrenceEnd)
        case .monthly:
            let recurrenceDays = self.selectedMonthDays.compactMap({ $0 }) as [NSNumber]
            self.recurrenceRule = EKRecurrenceRule(recurrenceWith: self.selectedRule, interval: 1, daysOfTheWeek: nil, daysOfTheMonth: recurrenceDays, monthsOfTheYear: (1...12).compactMap { NSNumber(value: $0) }, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: self.recurrenceEnd)
        case .yearly:
            let recurrenceDays = self.selectedMonthDays.compactMap({ $0 }) as [NSNumber]
            let month: NSNumber = NSNumber(value: self.frequencyMonthDate ?? 0 + 2)
            self.recurrenceRule = EKRecurrenceRule(recurrenceWith: self.selectedRule, interval: 1, daysOfTheWeek: nil, daysOfTheMonth: recurrenceDays, monthsOfTheYear: [month], weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: self.recurrenceEnd)
        default:
            print("Error unsupported recurrence selected: \(self.selectedRule)")
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
            self.clearNotesInput()
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
    
    private func clearNotesInput() {
        self.isNotesInputOpen = false
        self.notesInput = ""
    }
    
    private func clearRecurrence() {        
        self.isRecurrencePickerOpen = false
        self.isRecurrenceUsingOccurences = false
        self.recurrenceRule = nil
        self.recurrenceEnd = nil
        self.endRecurrenceDate = nil
        self.endRecurrenceTime = nil
        self.numberOfOccurences = nil
        self.frequencyDayValueInt = nil
        self.selectedMonthDays = []
        self.frequencyWeekdayValues = []
        self.dayFrequencyText = ""
        self.frequencyMonthDate = Date().get(.month) - 1
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
        if self.isRecurrencePickerOpen, !self.isDateTimePickerOpen || self.newItemEndDate == nil {
            self.displayToast("End Date Required")
            return
        }
        Task {
            let startDateComponents = self.newItemStartDate
            let startTimeComponents = self.newItemStartTime
            let endTimeComponents = self.newItemEndTime
            let endDateComponents = self.newItemEndDate
            var mergedStartComponments: DateComponents?
            var mergedEndComponments: DateComponents?
            if startDateComponents != nil {
                mergedStartComponments = DateComponents()
                mergedStartComponments?.year = startDateComponents?.year
                mergedStartComponments?.month = startDateComponents?.month
                mergedStartComponments?.day = startDateComponents?.day
                // Not possible to have a date without the first three
                if startTimeComponents != nil {
                    mergedStartComponments?.hour = startTimeComponents?.hour
                    mergedStartComponments?.minute = startTimeComponents?.minute
                    mergedStartComponments?.second = startTimeComponents?.second
                }
            }
            if endDateComponents != nil {
                mergedEndComponments = DateComponents()
                mergedEndComponments?.year = endDateComponents?.year
                mergedEndComponments?.month = endDateComponents?.month
                mergedEndComponments?.day = endDateComponents?.day
                if endTimeComponents != nil {
                    mergedEndComponments?.hour = endTimeComponents?.hour
                    mergedEndComponments?.minute = endTimeComponents?.minute
                    mergedEndComponments?.second = endTimeComponents?.second
                }
            }
            if self.editMode {
                if self.isNotesInputOpen {
                    self.calendarItem?.notes = self.notesInput
                }
                if let event = self.calendarItem as? EKEvent,
                   let startComponents = mergedStartComponments,
                   let endComponents = mergedEndComponments,
                   let startDate = Calendar.current.date(from: startComponents),
                   let endDate = Calendar.current.date(from: endComponents) {
                    self.saveNewDates(for: event, newStart: startDate, newEnd: endDate)
                } else if let reminder = self.calendarItem as? EKReminder {
                    self.saveNewDates(for: reminder, newStart: mergedStartComponments, newEnd: mergedEndComponments)
                }
            } else if let startComponents = mergedStartComponments,
                      let endComponents = mergedEndComponments,
                      let startDate = Calendar.current.date(from: startComponents),
                      let endDate = Calendar.current.date(from: endComponents) {
                await self.createEvent(start: startDate, end: endDate)
            } else {
                let start = mergedStartComponments != nil ? mergedStartComponments : nil
                let end = mergedEndComponments != nil ? mergedEndComponments : nil
                await self.createReminder(start: start, end: end)
            }
        }
    }
    
    @MainActor private func createEvent(start startDate: Date, end endDate: Date) async {
        do {
            let newEvent = try await EventKitManager.shared.createEvent(self.newItemTitle, startDate: startDate, endDate: endDate)
            if self.isNotesInputOpen {
                newEvent.notes = self.notesInput
            }
            self.save(event: newEvent, "Event Created")
        } catch let error as NSError {
            print("Error: failed to save event with error : \(error)")
        }
    }
    
    /// If there is a Start and End date make an Event from the given info, or save an existing Event with any modified info
    @MainActor private func saveNewDates(for event: EKEvent, newStart startDate: Date, newEnd endDate: Date) {
        Task {
            event.title = self.newItemTitle
            event.startDate = startDate
            event.endDate = endDate
            self.save(event: event, "Event Saved")
        }
    }
    
    @MainActor private func save(event: EKEvent, _ message: String) {
        self.handleRecurrence(for: event)
        do {
            try EventKitManager.shared.eventStore.save(event, span: .futureEvents)
        } catch  {
            print("Error saving event: \(error)")
        }
        self.displayToast(message)
        self.reset()
    }
    
    @MainActor private func createReminder(start startComponents: DateComponents?, end endComponents: DateComponents?) async {
        do {
            let newReminder = try await EventKitManager.shared.createReminder(self.newItemTitle, startDate: startComponents, dueDate: endComponents)
            if self.isNotesInputOpen {
                newReminder.notes = self.notesInput
            }
            self.save(reminder: newReminder, "Reminder Created")
        } catch let error as NSError {
            print("Error: failed to Create Reminder with error: \(error)")
        }
    }
    
    /// If there is a Start and End date make an Reminder from the given info, or save an existing Reminder with any modified info
    @MainActor private func saveNewDates(for reminder: EKReminder, newStart startComponents: DateComponents?, newEnd endComponents: DateComponents?) {
        Task {
            reminder.title = self.newItemTitle
            reminder.startDateComponents = startComponents
            reminder.dueDateComponents = endComponents
            self.save(reminder: reminder, "Reminder Saved")
        }
    }
    
    @MainActor public func save(reminder: EKReminder, _ message: String) {
        self.handleRecurrence(for: reminder)
        do {
            try EventKitManager.shared.eventStore.save(reminder, commit: true)
        } catch let error as NSError {
            print("Error: failed to Save Reminder with error: \(error)")
        }
        self.displayToast(message)
        self.reset()
    }
    
    /// Update the Toast notification to alert the user
    @MainActor public func displayToast(_ message: String) {
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
