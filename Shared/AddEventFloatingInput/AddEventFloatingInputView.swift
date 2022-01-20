//
//  AddEventFloatingTextField.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/6/22.
//

import SwiftUI
import EventKit

struct AddEventFloatingInputView: View {
    
    @State var newEventName: String = ""
    @State var newStartEventDate: Date?
    @State var newEndEventDate: Date?
    /// True for reminders, false for events
    @AppStorage("default_save_type") var isReminder: Bool = true
    @Binding var isShowingBackgroundBlur: Bool
    @Binding var isShowingDatePicker: Bool
    var isNewEventFocused: FocusState<Bool>.Binding
    
    private let eventStore = EKEventStore()
    
    private let barHeight: CGFloat = 44
    
    var body: some View {
        VStack {
            HStack {
                AddEventDatePicker(startDate: self.$newStartEventDate, endDate: self.$newEndEventDate, isDisplayed: self.$isShowingDatePicker, isShowingDatePicker: self.$isShowingDatePicker)
            }
            .padding(.bottom, 11)
            .opacity((self.isNewEventFocused.wrappedValue || self.isShowingDatePicker) ? 1 : 0)
            HStack {
                HStack {
                    Button(action: self.toggleToEventOrReminder) {
                        Image(systemName: self.isReminder ? "list.bullet" : "calendar.badge.plus")
                    }.buttonStyle(.plain)
                        .frame(width: 36, height: 36)
                        .padding(.leading, 10)
                    TextField("", text: self.$newEventName)
                        .focused(self.isNewEventFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            self.addEvent()
                        }
                        .onTapGesture {
                            withAnimation {
                                self.isShowingDatePicker = self.newStartEventDate != nil || self.newEndEventDate != nil
                            }
                        }
                        .foregroundColor(Color.dark)
                        .placeholder(when: self.newEventName.isEmpty) {
                            Text(self.isReminder ? "New Reminder" : "New Event").foregroundColor(.gray)
                        }
                    Button(action: self.addEvent) {
                        Image(systemName: "plus")
                            .frame(width: self.barHeight, height: self.barHeight)
                            .foregroundColor(Color.dark)
                    }.buttonStyle(.plain)
                }
                .frame(width: 362, height: self.barHeight)
                .background(RoundedRectangle(cornerRadius: 13)
                                .fill(Color(uiColor: .systemGray6))
                                .shadow(radius: 4, x: 2, y: 4))
            }
        }
        .padding(14)
    }
    
    private func toggleToEventOrReminder() {
        withAnimation {
            self.isReminder.toggle()
        }
    }
    
    private func createEventOrReminder() {
        if self.isReminder {
            self.addReminder()
        } else {
            self.addEvent()
        }
    }
    
    private func addEvent() {
        if let startDate = self.newStartEventDate, let endDate = self.newEndEventDate {
            Task {
                do {
                    let newEvent = try await EventManager.shared.createEvent(self.newEventName, startDate: startDate, endDate: endDate)
                    EventManager.shared.events.append(newEvent)
                    print("Saved Event")
                    // TODO Recurring and Alarms
                    self.newEventName = ""
                    self.isNewEventFocused.wrappedValue = false
                    self.isShowingDatePicker = false
                    self.isShowingBackgroundBlur = false
                    self.newStartEventDate = nil
                    self.newEndEventDate = nil
                } catch let error as NSError {
                    print("failed to save event with error : \(error)")
                }
            }
        } else {
            // TODO show alert 
        }
    }
    
    private func addReminder() {
        let reminder: EKReminder = EKReminder(eventStore: self.eventStore)
        reminder.title = self.newEventName
//        reminder.priority = 2
        //  How to show completed
        //reminder.completionDate = Date()
        // TODO alarms, priority, completion, etc.
        reminder.calendar = self.eventStore.defaultCalendarForNewReminders()

        do {
          try self.eventStore.save(reminder, commit: true)
        } catch {
          print("Cannot save Reminder")
          return
        }
        print("Reminder saved")
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
