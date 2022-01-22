//
//  AddEventFloatingTextField.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/6/22.
//

import SwiftUI
import EventKit

struct AddEventFloatingInputView: View {
    
    @EnvironmentObject var viewModel: AddEventViewModel
    @FocusState var isNewEventFocused: Bool
    @Binding var isBackgroundBlurred: Bool
    private let barHeight: CGFloat = 44
    
    @ViewBuilder var eventOptions: some View {
        HStack {
            AddRecurrenceRule()
        }
        .padding(.bottom, 11)
        HStack {
            AddEventDateTimePicker()
        }
        .padding(.bottom, 11)
    }
    
    var body: some View {
        VStack {
            eventOptions
                .opacity(self.isBackgroundBlurred ? 1 : 0)
            HStack {
                HStack {
                    Button(action: self.displayEmojiPicker) {
                        Image("smile.face")
                            .resizable()
                            .frame(width: 25, height: 25)
                    }.buttonStyle(.plain)
                        .frame(width: 36, height: 36)
                        .padding(.leading, 10)
                    TextField("", text: self.viewModel.newItemTitleBinding)
                        .focused(self.$isNewEventFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            self.addEvent()
                        }
                        .onTapGesture {
                            withAnimation {
                                self.viewModel.isTimePickerOpen = self.viewModel.newItemStartDate != nil || self.viewModel.newItemEndDate != nil
                                self.isBackgroundBlurred = true
                            }
                        }
                        .foregroundColor(Color.dark)
                        .placeholder(when: self.viewModel.newItemTitle.isEmpty) {
                            Text("New Event").foregroundColor(.gray)
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
                                .shadow(radius: 4, x: 2, y: 2))
            }
        }
        .padding(14)
    }
    
    private func displayEmojiPicker() {
        print("TODO Emoji Picker")
    }
    
    private func createEventOrReminder() {
        print("TODO Create Event or Reminder")
//        if self.isReminder {
//            self.addReminder()
//        } else {
//            self.addEvent()
//        }
    }
    
    private func addEvent() {
//        if let startDate = self.viewModel.a, let endDate = self.newEndEventDate {
//            Task {
//                do {
//                    let newEvent = try await EventManager.shared.createEvent(self.newEventName, startDate: startDate, endDate: endDate)
//                    EventManager.shared.events.append(newEvent)
//                    print("Saved Event")
//                    // TODO Recurring and Alarms
//                    self.newEventName = ""
//                    self.isNewEventFocused.wrappedValue = false
//                    self.isShowingDatePicker = false
//                    self.isShowingBackgroundBlur = false
//                    self.newStartEventDate = nil
//                    self.newEndEventDate = nil
//                } catch let error as NSError {
//                    print("failed to save event with error : \(error)")
//                }
//            }
//        } else {
//            // TODO show alert
//        }
    }
    
    private func addReminder() {
//        let reminder: EKReminder = EKReminder(eventStore: self.eventStore)
//        reminder.title = self.newEventName
////        reminder.priority = 2
//        //  How to show completed
//        //reminder.completionDate = Date()
//        // TODO alarms, priority, completion, etc.
//        reminder.calendar = self.eventStore.defaultCalendarForNewReminders()
//
//        do {
//          try self.eventStore.save(reminder, commit: true)
//        } catch {
//          print("Cannot save Reminder")
//          return
//        }
//        print("Reminder saved")
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
