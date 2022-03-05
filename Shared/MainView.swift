//
//  MainView.swift
//  Shared
//
//  Created by Michael Ellis on 1/2/22.
//

import SwiftUI
import CoreData
import EventKit

struct MainView: View {
    
    private let date = Date()
    
    @FocusState private var isDailyGoalFocused: Bool
    
    @StateObject private var addEventViewModel: ModifyCalendarItemViewModel = ModifyCalendarItemViewModel()
    
    init() {}
    
    var body: some View {
        ZStack {
            // Primary Display
            VStack {
                MainHeader(for: self.date)
                DailyGoalTextField(isDailyGoalFocused: self.$isDailyGoalFocused)
                Spacer()
                // Clock View todo in v2
                Divider()
                EventsAndRemindersMainList()
            }
            // Blurred Background
            .if(self.addEventViewModel.isAddEventTextFieldFocused) { view in
                view.background(Color.black.opacity(0.6)
                                    .blur(radius: 1))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .blur(radius: 1)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            self.addEventViewModel.isAddEventTextFieldFocused = false
                        }
                    }
            }
            // Cover up the event list and background views when the Floating Event Input is open
            if self.addEventViewModel.isAddEventTextFieldFocused {
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            self.addEventViewModel.isAddEventTextFieldFocused = false
                        }
                    }
            }
            VStack {
                Spacer()
                FloatingEventInput(isBackgroundBlurred: self.$addEventViewModel.isAddEventTextFieldFocused)
                    .onChange(of: self.addEventViewModel.isAddEventTextFieldFocused, perform: { isFocused in
                        if isFocused { self.addEventViewModel.isAddEventTextFieldFocused = true }
                    })
                    .environmentObject(self.addEventViewModel)
            }
        }
    }
}
