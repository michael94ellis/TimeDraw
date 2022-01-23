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
    var recurrenceRule: EKRecurrenceRule?
    @Published var endRecurrenceDate: Date?
    @Published var numberOfOccurences: Int?
    @Published var recurrenceEnds: Bool = false
    @Published var selectedRule: EKRecurrenceFrequency = .weekly
    
    var endRecurrenceDateBinding: Binding<Date> { Binding<Date>(get: { self.endRecurrenceDate ?? self.setSuggestedEndRecurrenceDate() }, set: { self.endRecurrenceDate = $0 }) }
    public var newItemTitleBinding: Binding<String> {  Binding<String>(get: { self.newItemTitle }, set: { self.newItemTitle = $0 }) }
    public var newItemStartTimeBinding: Binding<Date?> {  Binding<Date?>(get: { self.newItemStartTime }, set: { self.newItemStartTime = $0 }) }
    public var newItemEndTimeBinding: Binding<Date?> {  Binding<Date?>(get: { self.newItemEndTime }, set: { self.newItemEndTime = $0 }) }
    public var newItemStartDateBinding: Binding<Date?> {  Binding<Date?>(get: { self.newItemStartDate }, set: { self.newItemStartDate = $0 }) }
    public var newItemEndDateBinding: Binding<Date?> {  Binding<Date?>(get: { self.newItemEndDate }, set: { self.newItemEndDate = $0 }) }
    
    @Published var isDisplayingOptions: Bool = false
    @Published var isDateTimePickerOpen: Bool = false
    @Published var isRecurrencePickerOpen: Bool = false
    @Published var isLocationTextFieldOpen: Bool = false
    
    public var isFocused: Bool {
        self.isDateTimePickerOpen || self.isRecurrencePickerOpen || self.isLocationTextFieldOpen
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
    
    private func reset() {
        DispatchQueue.main.async {
            self.isDisplayingOptions = false
            self.isDateTimePickerOpen = false
            self.isRecurrencePickerOpen = false
            self.isLocationTextFieldOpen = false
            
            self.newItemTitle = ""
            self.newItemStartDate = nil
            self.newItemEndDate = nil
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
                let newEvent = try await EventManager.shared.createReminder(self.newItemTitle, startDate: self.newItemStartDate, dueDate: self.newItemEndDate)
                // TODO add recurrence and stuff
                await MainActor.run {
                    EventManager.shared.reminders.append(newEvent)
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
            self.recurrenceRule?.recurrenceEnd = EKRecurrenceEnd(end: suggestedEndDate)
            return suggestedEndDate
        }
        return endDate
    }
}
