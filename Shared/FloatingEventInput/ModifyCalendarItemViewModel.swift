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
    
    @Published var newItemCreated: Bool = false
    // MARK: - New EKCalendarItem Data
    @Published var calendarItem: EKCalendarItem?
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
    
    // MARK: - Recurrence Rule Data
    private var recurrenceRule: EKRecurrenceRule?
    private var recurrenceEnd: EKRecurrenceEnd?
    @Published var endRecurrenceDate: DateComponents?
    @Published var endRecurrenceTime: DateComponents?
    @Published var numberOfOccurences: Int?
    @Published var isRecurrenceUsingOccurences: Bool = false
    @Published var frequencyDayValueInt: Int?
    @Published var frequencyWeekdayValue: EKWeekday = .monday
    @Published var frequencyMonthDate: Int?
    @Published var selectedRule: EKRecurrenceFrequency = .weekly {
        didSet {
            print(self.selectedRule)
        }
    }
    
    // MARK: - Display State vars
    
    @Published var isAddEventTextFieldFocused: Bool = false
    @Published var isDisplayingOptions: Bool = false
    @Published var isDateTimePickerOpen: Bool = false
    @Published var isRecurrencePickerOpen: Bool = false
    @Published var isLocationTextFieldOpen: Bool = false
    public var isFocused: Bool {
        self.isDateTimePickerOpen || self.isRecurrencePickerOpen || self.isLocationTextFieldOpen
    }
    
    private var getSelectedWeekDays: [EKRecurrenceDayOfWeek] {
        return EKWeekday.allCases.compactMap {
            guard self.frequencyWeekdayValue == $0 else {
                return nil
            }
            return EKRecurrenceDayOfWeek($0)
        }
    }
    
    init() {
        if let month = Calendar.current.dateComponents([.month], from: Date()).month {
            self.frequencyMonthDate = month - 1
        }
        let daysInThisWeek = Calendar.current.daysWithSameWeekOfYear(as: Date())
        self.daysOfTheWeek = daysInThisWeek.compactMap { self.weekdayFormatter.string(from: $0) }
    }
    
    @MainActor func open(event: EKEvent) {
        self.reset()
        self.calendarItem = event
        self.newItemTitle = event.title
        self.newItemStartTime = event.startDate.get(.hour, .minute, .second)
        self.newItemEndTime = event.endDate.get(.hour, .minute, .second)
        self.newItemStartDate = event.startDate.get(.month, .day, .year)
        self.newItemEndDate = event.endDate.get(.month, .day, .year)
        if let recurrenceRule = event.recurrenceRules?.first {
            self.recurrenceRule = recurrenceRule
            self.recurrenceEnd = recurrenceRule.recurrenceEnd
            if let recurrenceEndDate = recurrenceRule.recurrenceEnd?.endDate {
                self.endRecurrenceDate = recurrenceEndDate.get(.month, .day, .year)
                self.endRecurrenceTime = recurrenceEndDate.get(.hour, .minute, .second)
            }
            // FIXME
            self.numberOfOccurences = nil
            self.frequencyDayValueInt = nil
            self.frequencyMonthDate = nil
        }
    }
    
    @MainActor func open(reminder: EKReminder) {
        self.reset()
        self.calendarItem = reminder
        self.newItemTitle = reminder.title
        self.newItemStartTime = reminder.startDateComponents?.date?.get(.hour, .minute, .second)
        self.newItemEndTime = reminder.dueDateComponents?.date?.get(.hour, .minute, .second)
        self.newItemStartDate = reminder.startDateComponents?.date?.get(.month, .day, .year)
        self.newItemEndDate = reminder.dueDateComponents?.date?.get(.month, .day, .year)
        if let recurrenceRule = reminder.recurrenceRules?.first {
            self.recurrenceRule = recurrenceRule
            self.recurrenceEnd = recurrenceRule.recurrenceEnd
            if let recurrenceEndDate = recurrenceRule.recurrenceEnd?.endDate {
                self.endRecurrenceDate = recurrenceEndDate.get(.month, .day, .year)
                self.endRecurrenceTime = recurrenceEndDate.get(.hour, .minute, .second)
            }
            // FIXME
            self.numberOfOccurences = nil
            self.frequencyDayValueInt = nil
            self.frequencyMonthDate = nil
        }
    }
    
    func addTimeToEvent() {
        withAnimation {
            self.isDateTimePickerOpen = true
        }
    }
    
    func removeTimeFromEvent() {
        withAnimation {
            self.isDateTimePickerOpen = false
        }
    }
    
    func openRecurrencePicker() {
        withAnimation {
            self.isRecurrencePickerOpen = true
        }
    }
    
    func closeRecurrencePicker() {
        withAnimation {
            self.isRecurrencePickerOpen = false
        }
    }
    
    public func createEventOrReminder() {
        self.addEvent()
    }
    
    private func setRecurrenceRule() {
        let interval = self.frequencyDayValueInt ?? 1
        switch self.selectedRule {
        case .daily:
            self.recurrenceRule = EKRecurrenceRule(recurrenceWith: selectedRule, interval: interval, end: self.recurrenceEnd)
        case .weekly:
            self.recurrenceRule = EKRecurrenceRule(recurrenceWith: self.selectedRule, interval: interval, daysOfTheWeek: self.getSelectedWeekDays, daysOfTheMonth: nil, monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: self.recurrenceEnd)
        case .monthly:
            self.recurrenceRule = EKRecurrenceRule(recurrenceWith: self.selectedRule, interval: 1, daysOfTheWeek: nil, daysOfTheMonth: [NSNumber(nonretainedObject: self.frequencyDayValueInt)], monthsOfTheYear: nil, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: self.recurrenceEnd)
        case .yearly:
            self.recurrenceRule = EKRecurrenceRule(recurrenceWith: self.selectedRule, interval: 1, daysOfTheWeek: nil, daysOfTheMonth: [NSNumber(nonretainedObject: self.frequencyDayValueInt)], monthsOfTheYear: (1...12).compactMap { NSNumber(value: $0) }, weeksOfTheYear: nil, daysOfTheYear: nil, setPositions: nil, end: self.recurrenceEnd)
        @unknown default:
            print(self.selectedRule)
        }
        
    }
    
    @MainActor func reset() {
        withAnimation {
            self.isAddEventTextFieldFocused = false
            self.isDisplayingOptions = false
            self.isDateTimePickerOpen = false
            self.isRecurrencePickerOpen = false
            self.isLocationTextFieldOpen = false
            
            self.calendarItem = nil
            self.newItemTitle = ""
            self.newItemStartTime = nil
            self.newItemEndTime = nil
            self.newItemStartDate = nil
            self.newItemEndDate = nil
            self.recurrenceRule = nil
            self.recurrenceEnd = nil
            self.endRecurrenceDate = nil
            self.endRecurrenceTime = nil
            self.numberOfOccurences = nil
            self.frequencyDayValueInt = nil
            self.frequencyMonthDate = nil
        }
        EventListViewModel.shared.updateData()
    }
    
    @MainActor func delete() {
        if let event = self.calendarItem as? EKEvent {
            try? EventKitManager.shared.eventStore.deleteEvent(identifier: event.calendarItemIdentifier)
        }
        if let reminder = self.calendarItem as? EKReminder {
            try? EventKitManager.shared.eventStore.deleteReminder(identifier: reminder.calendarItemIdentifier)
        }
        self.reset()
    }
    
    private func addEvent() {
        guard let startDateComponents = self.newItemStartDate,
              let endDateComponents = self.newItemEndDate,
              let startTimeComponents = self.newItemStartTime,
              let endTimeComponents = self.newItemEndTime else {
                  self.addReminder()
                  return
              }
        var mergedStartComponments = DateComponents()
        mergedStartComponments.year = startDateComponents.year
        mergedStartComponments.month = startDateComponents.month
        mergedStartComponments.day = startDateComponents.day
        mergedStartComponments.hour = startTimeComponents.hour
        mergedStartComponments.minute = startTimeComponents.minute
        mergedStartComponments.second = startTimeComponents.second
        var mergedEndComponments = DateComponents()
        mergedEndComponments.year = endDateComponents.year
        mergedEndComponments.month = endDateComponents.month
        mergedEndComponments.day = endDateComponents.day
        mergedEndComponments.hour = endTimeComponents.hour
        mergedEndComponments.minute = endTimeComponents.minute
        mergedEndComponments.second = endTimeComponents.second
        guard let startDate = Calendar.current.date(from: mergedStartComponments),
              let endDate = Calendar.current.date(from: mergedEndComponments) else {
                  self.addReminder()
                  return
              }
        Task {
            do {
                let newEvent = try await EventKitManager.shared.createEvent(self.newItemTitle, startDate: startDate, endDate: endDate)
                if self.isRecurrencePickerOpen, let recurrenceRule = recurrenceRule {
                    newEvent.addRecurrenceRule(recurrenceRule)
                    try? EventKitManager.shared.eventStore.save(newEvent, span: .futureEvents)
                }
                print("Saved Event")
                await self.reset()
                await MainActor.run {
                    self.newItemCreated = true
                }
            } catch let error as NSError {
                print("Error: failed to save event with error : \(error)")
            }
        }
    }
    
    private func addReminder() {
        Task {
            let startDateComponents = self.newItemStartDate
            let startTimeComponents = self.newItemStartTime
            var mergedStartComponments: DateComponents?
            let endTimeComponents = self.newItemEndTime
            let endDateComponents = self.newItemEndDate
            var mergedEndComponments: DateComponents?
            if startDateComponents != nil || startTimeComponents != nil {
                mergedStartComponments = DateComponents()
                mergedStartComponments?.year = startDateComponents?.year
                mergedStartComponments?.month = startDateComponents?.month
                mergedStartComponments?.day = startDateComponents?.day
                mergedStartComponments?.hour = startTimeComponents?.hour
                mergedStartComponments?.minute = startTimeComponents?.minute
                mergedStartComponments?.second = startTimeComponents?.second
            }
            if endDateComponents != nil || endTimeComponents != nil {
                mergedEndComponments = DateComponents()
                mergedEndComponments?.year = endDateComponents?.year
                mergedEndComponments?.month = endDateComponents?.month
                mergedEndComponments?.day = endDateComponents?.day
                mergedEndComponments?.hour = endTimeComponents?.hour
                mergedEndComponments?.minute = endTimeComponents?.minute
                mergedEndComponments?.second = endTimeComponents?.second
            }
            do {
                let newReminder = try await EventKitManager.shared.createReminder(self.newItemTitle, startDate: mergedStartComponments, dueDate: mergedEndComponments)
                if self.isRecurrencePickerOpen, let recurrenceRule = recurrenceRule {
                    newReminder.addRecurrenceRule(recurrenceRule)
                    try? EventKitManager.shared.eventStore.save(newReminder, commit: true)
                }
                print("Saved Reminder")
                await MainActor.run {
                    self.newItemCreated = true
                }
                await self.reset()
            } catch let error as NSError {
                print("Error: failed to save reminder with error : \(error)")
            }
        }
    }
    
    func getRecentEmojis() -> [String] {
        guard let prefs = UserDefaults(suiteName: "com.apple.EmojiPreferences"),
              let defaults = prefs.dictionary(forKey: "EMFDefaultsKey"),
              let recents = defaults["EMFRecentsKey"] as? [String] else {
                  // No Recent Emojis
                  return ["No Recent Emojis"]
              }
        return recents
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
}
