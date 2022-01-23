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
    @State var isShowingEmojiPicker: Bool = false
    @Binding var isBackgroundBlurred: Bool
    private let barHeight: CGFloat = 44
    
    @ViewBuilder var eventOptions: some View {
        HStack {
            AddRecurrenceRule()
        }
        .padding(.bottom, 8)
        HStack {
            AddEventDateTimePicker()
        }
        .padding(.bottom, 8)
    }
    
    var body: some View {
        VStack {
            eventOptions
                .opacity(self.isBackgroundBlurred ? 1 : 0)
            HStack {
                HStack {
                    Menu(content: {
                        ForEach(self.viewModel.getRecentEmojis(), id: \.self) { emoji in
                            Button(emoji, action: {
                                self.viewModel.newItemTitle = "\(emoji) \(self.viewModel.newItemTitle)"
                            })
                                .frame(width: 30, height: 30)
                        }
                    }) {
                        Image("smile.face")
                            .resizable()
                            .frame(width: 25, height: 25)
                    }
                    TextField("", text: self.viewModel.newItemTitleBinding)
                        .focused(self.$isNewEventFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            self.viewModel.createEventOrReminder()
                        }
                        .onTapGesture {
                            withAnimation {
                                self.viewModel.isDateTimePickerOpen = self.viewModel.newItemStartDate != nil || self.viewModel.newItemEndDate != nil
                                self.isBackgroundBlurred = true
                            }
                        }
                        .placeholder(when: self.viewModel.newItemTitle.isEmpty) {
                            Text("New Event or Reminder").foregroundColor(.gray)
                        }
                    Button(action: self.viewModel.createEventOrReminder) {
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
