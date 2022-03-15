//
//  FloatingEventInput.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/6/22.
//

import SwiftUI
import EventKit
import AlertToast

struct FloatingEventInput: View {
    
    @ObservedObject var appSettings: AppSettings = .shared
    @EnvironmentObject var viewModel: ModifyCalendarItemViewModel
    
    @FocusState var isNewEventFocused: Bool
    @Binding var isBackgroundBlurred: Bool
    @State var showCalendarPickerMenu: Bool = false
    
    
    let defaultCalendarColor: CGColor = EventKitManager.shared.defaultReminderCalendar?.cgColor ?? .init(red: 55, green: 91, blue: 190, alpha: 1)
    private let barHeight: CGFloat = 44
    
    @ViewBuilder func topButton(image: String, color: Color, action: @escaping () -> ()) -> some View {
        Button(action: {
            withAnimation {
                action()
            }
        }) {
//            Group { // Meaningless Container
                Image(systemName: image)
                    .resizable()
                    .frame(width: 30, height: 32)
                    .foregroundColor(color)
        }
        .frame(width: 55, height: 55)
        .background(RoundedRectangle(cornerRadius: 13)
                        .fill(Color(uiColor: .systemGray6))
                        .shadow(radius: 4, x: 2, y: 4))
        .contentShape(Rectangle())
        .buttonStyle(.plain)
    }
    
    @ViewBuilder var selectCalendarButton: some View {
        if self.appSettings.showCalendarPickerButton {
            Menu(content: {
                ForEach(self.appSettings.userSelectedCalendars.loadCalendarIds(), id: \.self) { calendarId in
                    if let calendar = EventKitManager.shared.eventStore.calendar(withIdentifier: calendarId) {
                        Button(action: {
                            self.viewModel.selectedCalendar = calendar
                        }) {
                            Text(calendar.title)
                        }
                    }
                }
            }) {
                self.topButton(image: "calendar", color: Color(cgColor: self.viewModel.selectedCalendar?.cgColor ?? self.defaultCalendarColor), action: { self.showCalendarPickerMenu.toggle() })
            }
            .gesture(TapGesture().onEnded({
                withAnimation {
                    self.viewModel.isAddEventTextFieldFocused = true
                }
            }))
        }
    }
    
    @ViewBuilder var eventOptions: some View {
        GeometryReader { container in
            ScrollView {
                VStack {
                    HStack {
                        if self.viewModel.editMode {
                            self.topButton(image: "xmark.square", color: .lightGray, action: { self.viewModel.reset() })
                            self.selectCalendarButton
                            Spacer()
                        } else {
                            self.selectCalendarButton
                            Spacer()
                        }
                        self.topButton(image: "trash", color: .red1, action: { self.viewModel.delete() })
                    }
                    .frame(maxWidth: 600)
                    .padding(.bottom, 8)
                    if self.appSettings.showNotes || self.viewModel.calendarItem?.hasNotes ?? false {
                        HStack {
                            AddNotesInput()
                        }
                        .padding(.bottom, 8)
                        .onTapGesture {}
                    }
                    if self.appSettings.showRecurringItems || self.viewModel.calendarItem?.hasRecurrenceRules ?? false {
                        HStack {
                            AddRecurrenceRule()
                        }
                        .padding(.bottom, 8)
                        .onTapGesture {}
                    }
                    HStack {
                        AddEventDateTimePicker()
                    }
                    .onTapGesture {}
                }.background(
                    Color.gray.opacity(0.01)
                        .gesture(TapGesture().onEnded({
                            withAnimation {
                                self.viewModel.isAddEventTextFieldFocused = false
                            }
                        })))
                    .frame(minWidth: container.size.width, minHeight: container.size.height, alignment: .bottom)
                    .contentShape(Rectangle())
            }
            .gesture(TapGesture().onEnded({
                withAnimation {
                    self.viewModel.isAddEventTextFieldFocused = false
                }
            }))
        }
    }
    
    var floatingTextBar: some View {
        HStack {
            EmojiButton()
            TextField("", text: self.$viewModel.newItemTitle)
                .focused(self.$isNewEventFocused)
                .onChange(of: self.viewModel.isAddEventTextFieldFocused) {
                    // Handle changes of the textfield focus from the view model's perspective
                    self.viewModel.isAddEventTextFieldFocused = $0
                    self.isNewEventFocused = $0
                }
                .submitLabel(.done)
                .onSubmit {
                    // User tapped Keyboard Done button
//                        self.viewModel.submitEventOrReminder()
                    self.isNewEventFocused = false
                }
                .gesture(TapGesture().onEnded({
                    // User tapped textfield - is attempting to add event
                    withAnimation {
                        self.isBackgroundBlurred = true
                        self.isNewEventFocused = true
                    }
                }))
                .placeholder(when: self.viewModel.newItemTitle.isEmpty) {
                    Text("New Event or Reminder").foregroundColor(.gray)
                }
            // Submit Button
            // TODO Show something other than checkmark for failed submit
            Button(action: {
                // User submitted event by tapping plus
                self.viewModel.submitEventOrReminder()
                self.isNewEventFocused = false
            }) {
                Image(systemName: self.viewModel.displayToast ? "checkmark.circle" : self.viewModel.editMode ? "circle" : "plus")
                    .frame(width: self.barHeight, height: self.barHeight)
                    .foregroundColor(Color(uiColor: .label))
                    .frame(width: 60, height: 55)
                    .background(.clear)
            }
        }
        .frame(height: self.barHeight)
        .frame(maxWidth: 600)
        .background(RoundedRectangle(cornerRadius: 13)
                        .fill(Color(uiColor: .systemGray6))
                        .shadow(radius: 4, x: 2, y: 2))
    }
    
    var body: some View {
        VStack {
            Spacer()
            HStack(alignment: .bottom) {
                self.eventOptions
                    .opacity(self.isBackgroundBlurred ? 1 : 0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.bottom, 8)
            self.floatingTextBar
        }
        .padding(14)
        .toast(isPresenting: Binding<Bool>(get: { self.viewModel.displayToast }, set: { self.viewModel.displayToast = $0 }), duration: 2, tapToDismiss: true, alert: {
            AlertToast(displayMode: .alert, type: .regular, title: self.viewModel.toastMessage)
        }, completion: {
            //Completion block after dismiss
            self.viewModel.displayToast = false
        })
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
