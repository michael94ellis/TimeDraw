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
    @State var isShowingEmojiPicker: Bool = false
    @Binding var isBackgroundBlurred: Bool
    private let barHeight: CGFloat = 44
    @State var emojiSelection: String = ""
    @State var showCalendarPickerMenu: Bool = false
    let defaultCalendarColor: CGColor = EventKitManager.shared.defaultReminderCalendar?.cgColor ?? .init(red: 55, green: 91, blue: 190, alpha: 1)
    
    @ViewBuilder func topButton(image: String, color: Color, action: @escaping () -> ()) -> some View {
        Button(action: {
            withAnimation {
                action()
            }
        }) {
            Group { // Meaningless Container}
                Image(systemName: image)
                    .resizable()
                    .frame(width: 30, height: 32)
                    .foregroundColor(color)
            }
            .frame(width: 55, height: 55)
        }
        .background(RoundedRectangle(cornerRadius: 13)
                        .fill(Color(uiColor: .systemGray6))
                        .shadow(radius: 4, x: 2, y: 4))
        .buttonStyle(.plain)
        .contentShape(Rectangle())
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
    
    let degreesToFlip: Double = 180
    @ViewBuilder var eventOptions: some View {
        ScrollView {
            VStack {
                HStack {
                    AddEventDateTimePicker()
                }
                .rotationEffect(.degrees(self.degreesToFlip))
                .onTapGesture {}
                if self.appSettings.showRecurringItems || self.viewModel.calendarItem?.hasRecurrenceRules ?? false {
                    HStack {
                        AddRecurrenceRule()
                    }
                    .padding(.bottom, 8)
                    .rotationEffect(.degrees(self.degreesToFlip))                }
                if self.appSettings.showNotes || self.viewModel.calendarItem?.hasNotes ?? false {
                    HStack {
                        AddNotesInput()
                    }
                    .padding(.bottom, 8)
                    .rotationEffect(.degrees(self.degreesToFlip))
                    .onTapGesture {}
                }
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
                .rotationEffect(.degrees(self.degreesToFlip))
            }.background(
                Color.gray.opacity(0.01)
                    .gesture(TapGesture().onEnded({
                        withAnimation {
                            self.viewModel.isAddEventTextFieldFocused = false
                        }
                    })))
        }
        .rotationEffect(.degrees(self.degreesToFlip))
        .border(.red)
        .gesture(TapGesture().onEnded({
            withAnimation {
                self.viewModel.isAddEventTextFieldFocused = false
            }
        }))
    }
    
    let numberOfEmojiColumns: Int = 5
    let emojiButtonWidth: Int = 45
    let emojiButtonHeight: Int = 40
    
    var emojiPopoverSize: CGSize {
        let emojiListCount = self.viewModel.getRecentEmojis().count
        let emojiPopoverWidth = emojiListCount >= self.numberOfEmojiColumns ?
        self.emojiButtonWidth * self.numberOfEmojiColumns :
        emojiListCount * self.emojiButtonWidth
        let emojiPopoverHeight = (emojiListCount / self.numberOfEmojiColumns + emojiListCount % self.numberOfEmojiColumns) * self.emojiButtonHeight
        return CGSize(width: emojiPopoverWidth, height: emojiPopoverHeight)
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
            HStack {
                PopoverButton(showPopover: self.$isShowingEmojiPicker,
                              popoverSize: self.emojiPopoverSize,
                              content: {
                    Image("smile.face")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .gesture(TapGesture().onEnded({
                            withAnimation {
                                self.isShowingEmojiPicker.toggle()
                            }
                        }))
                }, popoverContent: {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: self.numberOfEmojiColumns)) {
                        ForEach(self.viewModel.getRecentEmojis(), id: \.self) { emoji in
                            Button(emoji, action: {
                                self.viewModel.newItemTitle = "\(emoji) \(self.viewModel.newItemTitle)"
                                self.isShowingEmojiPicker.toggle()
                            })
                                .frame(width: CGFloat(self.emojiButtonWidth), height: CGFloat(self.emojiButtonHeight))
                        }
                    }
                    .padding(.horizontal)
                })
                    .padding(.leading, 12)
                    .padding(.trailing, 5)
                TextField("", text: self.viewModel.newItemTitleBinding)
                    .focused(self.$isNewEventFocused)
                    .onChange(of: self.viewModel.isAddEventTextFieldFocused) {
                        // Handle changes of the textfield focus from the view model's perspective
                        self.viewModel.isAddEventTextFieldFocused = $0
                        self.isNewEventFocused = $0
                    }
                    .submitLabel(.done)
                    .onSubmit {
                        // User tapped Keyboard Done button
                        self.viewModel.submitEventOrReminder()
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
