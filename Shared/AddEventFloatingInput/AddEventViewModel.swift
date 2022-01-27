//
//  AddEventViewModel.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/21/22.
//

import Foundation
import EventKit
import SwiftUI

class AddEventViewModel: ObservableObject {
    
    // New Event/Reminder Data
    @Published var newItemTitle: String = ""
    // For the "Add Time" feature
    @Published var newItemStartTime: Date?
    @Published var newItemEndTime: Date?
    // For the "Add Date/Time" feature
    @Published var newItemStartDate: Date?
    @Published var newItemEndDate: Date?
    // Recurrence Rule Data
    private var recurrenceRule: EKRecurrenceRule?
    private var recurrenceEnd: EKRecurrenceEnd?
    @Published var endRecurrenceDate: Date?
    @Published var numberOfOccurences: Int?
    @Published var isRecurrenceUsingOccurences: Bool = false
    @Published var frequencyDayValueInt: Int?
    @Published var frequencyDayValueString: String = ""
    @Published var frequencyMonthDate: Int?
    @Published var selectedRule: EKRecurrenceFrequency = .weekly {
        didSet {
            print(self.selectedRule)
        }
    }
    
    let weekdayFormatter = DateFormatter(format: "E")
    var daysOfTheWeek = [String]()
    
    public var newItemTitleBinding: Binding<String> {  Binding<String>(get: { self.newItemTitle }, set: { self.newItemTitle = $0 }) }
    
    @Published var isAddEventTextFieldFocused: Bool = false
    @Published var isDisplayingOptions: Bool = false
    @Published var isDateTimePickerOpen: Bool = false
    @Published var isRecurrencePickerOpen: Bool = false
    @Published var isLocationTextFieldOpen: Bool = false
    
    public var isFocused: Bool {
        self.isDateTimePickerOpen || self.isRecurrencePickerOpen || self.isLocationTextFieldOpen
    }
    
    init() {
        if let month = Calendar.current.dateComponents([.month], from: Date()).month {
            self.frequencyMonthDate = month - 1
        }
        let daysInThisWeek = Calendar.current.daysWithSameWeekOfYear(as: Date())
        self.daysOfTheWeek = daysInThisWeek.compactMap { self.weekdayFormatter.string(from: $0) }
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
        if let recurrenceEnd = self.endRecurrenceDate {
            self.recurrenceEnd = EKRecurrenceEnd(end: recurrenceEnd)
        } else if let numberOfOccurences = numberOfOccurences {
            self.recurrenceEnd = EKRecurrenceEnd(occurrenceCount: numberOfOccurences)
        }
        self.setRecurrenceRule()
    }
    
    private func setRecurrenceRule() {
        self.recurrenceRule = EKRecurrenceRule(recurrenceWith: selectedRule, interval: 1, end: self.recurrenceEnd)
    }
    
    func reset() {
        DispatchQueue.main.async {
            withAnimation {
                self.isAddEventTextFieldFocused = false
                self.isDisplayingOptions = false
                self.isDateTimePickerOpen = false
                self.isRecurrencePickerOpen = false
                self.isLocationTextFieldOpen = false
                
                self.newItemTitle = ""
                self.newItemStartDate = nil
                self.newItemEndDate = nil
            }
        }
    }
    
    private func addEvent() {
        guard let startDate = self.newItemStartDate, let endDate = self.newItemEndDate else {
            // TODO handle
            self.addReminder()
            return
        }
        Task {
            do {
                let newEvent = try await EventManager.shared.createEvent(self.newItemTitle, startDate: startDate, endDate: endDate)
                if self.isRecurrencePickerOpen, let recurrenceRule = recurrenceRule {
                    newEvent.addRecurrenceRule(recurrenceRule)
                    try? EventManager.shared.eventStore.save(newEvent, span: .futureEvents)
                }
                // TODO add recurrence and stuff
                await MainActor.run {
                    EventManager.shared.events.append(newEvent)
                }
                print("Saved Event")
                self.reset()
            } catch let error as NSError {
                print("Error: failed to save event with error : \(error)")
            }
        }
    }
    
    private func addReminder() {
        Task {
            do {
                let newReminder = try await EventManager.shared.createReminder(self.newItemTitle, startDate: self.newItemStartDate, dueDate: self.newItemEndDate)
                if self.isRecurrencePickerOpen, let recurrenceRule = recurrenceRule {
                    newReminder.addRecurrenceRule(recurrenceRule)
                    try? EventManager.shared.eventStore.save(newReminder, commit: true)
                }
                // TODO add recurrence and stuff
                await MainActor.run {
                    EventManager.shared.reminders.append(newReminder)
                }
                print("Saved Reminder")
                self.reset()
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
    
    @discardableResult
    func setSuggestedEndRecurrenceDate() -> Date {
        guard let endDate = self.endRecurrenceDate else {
            var suggestedEndDate: Date
            switch self.selectedRule {
            case .daily: suggestedEndDate = Date().addingTimeInterval(60 * 60 * 24 * 31)
            case .weekly: suggestedEndDate = Date().addingTimeInterval(60 * 60 * 24 * 7 * 4)
            case .monthly: suggestedEndDate = Date().addingTimeInterval(60 * 60 * 24 * 30 * 6)
            case .yearly: suggestedEndDate = Date().addingTimeInterval(60 * 60 * 24 * 366 * 2)
            default: suggestedEndDate = Date().addingTimeInterval(60 * 60 * 24 * 5)
            }
            self.endRecurrenceDate = suggestedEndDate
            self.numberOfOccurences = nil
            return suggestedEndDate
        }
        return endDate
    }
}
