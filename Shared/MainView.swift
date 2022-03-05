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
    @ObservedObject private var eventManager: EventKitManager = .shared
    
    @StateObject private var addEventViewModel: AddEventViewModel = AddEventViewModel()
    
    init() {
        Task {
            try await EventKitManager.shared.fetchEventsForToday()
        }
        Task {
            try await EventKitManager.shared.fetchRemindersForToday()
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                MainHeader(for: self.date)
                DailyGoalTextField(isDailyGoalFocused: self.$isDailyGoalFocused)
                Spacer()
                // Clock View todo in v2
                Divider()
                EventsAndRemindersMainList()
            }
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
            VStack {
                Rectangle().fill(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            self.addEventViewModel.isAddEventTextFieldFocused = false
                        }
                    }
                AddEventFloatingInputView(isBackgroundBlurred: self.$addEventViewModel.isAddEventTextFieldFocused)
                    .onChange(of: self.addEventViewModel.isAddEventTextFieldFocused, perform: { isFocused in
                        if isFocused { self.addEventViewModel.isAddEventTextFieldFocused = true }
                    })
                    .environmentObject(self.addEventViewModel)
            }
        }
    }
}
