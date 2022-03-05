//
//  FloatingEventInput.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/6/22.
//

import SwiftUI
import EventKit

struct FloatingEventInput: View {
    
    @EnvironmentObject var viewModel: ModifyCalendarItemViewModel
    @FocusState var isNewEventFocused: Bool
    @State var isShowingEmojiPicker: Bool = false
    @Binding var isBackgroundBlurred: Bool
    private let barHeight: CGFloat = 44
    @State var emojiSelection: String = ""
    
    @ViewBuilder var eventOptions: some View {
        HStack {
            Spacer()
            Button(action: {
                withAnimation {
                    self.viewModel.reset()
                }
            }) {
                Image(systemName: "trash")
                    .resizable()
                    .frame(width: 30, height: 32)
                    .foregroundColor(.red1)
            }
            .buttonStyle(.plain)
            .frame(width: 55, height: 55)
            .background(RoundedRectangle(cornerRadius: 13)
                            .fill(Color(uiColor: .systemGray6))
                            .shadow(radius: 4, x: 2, y: 4))
        }
        .padding(.bottom, 8)
        HStack {
            AddRecurrenceRule()
        }
        .padding(.bottom, 8)
        HStack {
            AddEventDateTimePicker()
        }
        .padding(.bottom, 8)
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
            eventOptions
                .opacity(self.isBackgroundBlurred ? 1 : 0)
            HStack {
                HStack {
                    PopoverButton(showPopover: self.$isShowingEmojiPicker,
                                  popoverSize: self.emojiPopoverSize,
                                  content: {
                        Image("smile.face")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .onTapGesture {
                                self.isShowingEmojiPicker.toggle()
                            }
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
                        .edgesIgnoringSafeArea(.bottom)
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
                            self.viewModel.createEventOrReminder()
                            self.isNewEventFocused = false
                        }
                        .onTapGesture {
                            // User tapped textfield - is attempting to add event
                            withAnimation {
                                self.isBackgroundBlurred = true
                                self.isNewEventFocused = true
                            }
                        }
                        .placeholder(when: self.viewModel.newItemTitle.isEmpty) {
                            Text("New Event or Reminder").foregroundColor(.gray)
                        }
                    Button(action: {
                        // User submitted event by tapping plus
                        self.viewModel.createEventOrReminder()
                        self.isNewEventFocused = false
                    }) {
                        Image(systemName: "plus")
                            .frame(width: self.barHeight, height: self.barHeight)
                            .foregroundColor(Color(uiColor: .label))
                    }.buttonStyle(.plain)
                }
                .frame(height: self.barHeight)
                .frame(maxWidth: 600)
                .background(RoundedRectangle(cornerRadius: 13)
                                .fill(Color(uiColor: .systemGray6))
                                .shadow(radius: 4, x: 2, y: 2))
            }
        }
        .padding(14)
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
