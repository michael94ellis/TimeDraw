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
    
    @Published var newItemTitle: String = ""
    @Published var newItemStartDate: Date?
    @Published var newItemEndDate: Date?
    
    public var newItemTitleBinding: Binding<String> {  Binding<String>(get: { self.newItemTitle }, set: { self.newItemTitle = $0 }) }
    public var newItemStartDateBinding: Binding<Date?> {  Binding<Date?>(get: { self.newItemStartDate }, set: { self.newItemStartDate = $0 }) }
    public var newItemEndDateBinding: Binding<Date?> {  Binding<Date?>(get: { self.newItemEndDate }, set: { self.newItemEndDate = $0 }) }
    
    @Published var isDisplayingOptions: Bool = false
    @Published var isTimePickerOpen: Bool = false
    @Published var isDateTimePickerOpen: Bool = false
    @Published var isRecurrencePickerOpen: Bool = false
    @Published var isLocationTextFieldOpen: Bool = false
    
    public var isFocused: Bool {
        self.isTimePickerOpen || self.isDateTimePickerOpen || self.isRecurrencePickerOpen || self.isLocationTextFieldOpen
    }
    
    func addTimeToEvent() {
        withAnimation {
            self.isTimePickerOpen = true
        }
    }
    
    func removeTimeFromEvent() {
        withAnimation {
            self.isTimePickerOpen = false
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
}
