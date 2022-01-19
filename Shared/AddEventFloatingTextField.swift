//
//  AddEventFloatingTextField.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/6/22.
//

import SwiftUI
import EventKit

struct AddEventFloatingTextField: View {
    
    @State var newEventName: String = ""
    @State var newStartEventDate: Date? 
    @State var newEndEventDate: Date?
    @State var isShowingDatePicker: Bool = false
    @FocusState private var isNewEventFocused: Bool
    
    private let eventStore = EKEventStore()
    
    private let barHeight: CGFloat = 44
    
    var body: some View {
        VStack {
            if self.isNewEventFocused || self.isShowingDatePicker {
                HStack {
                    if self.isShowingDatePicker {
                        AddEventDatePicker(startDate: self.$newStartEventDate, endDate: self.$newEndEventDate, isDisplayed: self.$isShowingDatePicker)
                    } else {
                        Button(action: self.addTimeToEvent) {
                            Text("Add Date")
                                .frame(height: 48)
                                .foregroundColor(Color.blue1)
                                .background(RoundedRectangle(cornerRadius: 13).fill(Color.lightGray2).frame(width: 360, height: 60))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 11)
            }
            HStack {
                HStack {
                    Button(action: self.addEvent) {
                        Image("smile.face")
                            .resizable()
                            .frame(width: 22, height: 22)
                    }.buttonStyle(.plain)
                        .frame(width: 36, height: 36)
                        .padding(.leading, 10)
                    TextField("", text: self.$newEventName)
                        .focused(self.$isNewEventFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            self.addEvent()
                        }
                        .foregroundColor(Color.dark)
                        .placeholder(when: self.newEventName.isEmpty) {
                            Text("Event").foregroundColor(.gray)
                        }
                    Button(action: self.addEvent) {
                        Image(systemName: "plus")
                            .frame(width: self.barHeight, height: self.barHeight)
                            .foregroundColor(Color.dark)
                    }.buttonStyle(.plain)
                }
                .frame(width: 362, height: self.barHeight)
                .background(RoundedRectangle(cornerRadius: 13)
                                .fill(Color(uiColor: .systemGray6)))
            }
        }
        .padding(14)
    }
    
    private func addTimeToEvent() {
        self.isShowingDatePicker = true
    }
    private func removeTimeFromEvent() {
        self.isShowingDatePicker = false
    }
    
    private func addEvent() {
        if let startDate = self.newStartEventDate, let endDate = self.newEndEventDate {
            Task {
                do {
                    try await EventManager.shared.createEvent(self.newEventName, startDate: startDate, endDate: endDate)
                    print("Saved Event")
                    // TODO Recurring and Alarms
                    self.newEventName = ""
                    self.isNewEventFocused = false
                    self.isShowingDatePicker = false
                    
                } catch let error as NSError {
                    print("failed to save event with error : \(error)")
                    self.addReminder()
                }
            }
        } else {
            self.addReminder()
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
