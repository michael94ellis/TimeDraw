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
    @AppStorage("isDailyGoalEnabled") var isDailyGoalEnabled: Bool = true
    @ObservedObject private var eventList: EventListViewModel = .shared
    @State var swipeDirection: SwipeDirection = .left
    
    @StateObject private var addEventViewModel: ModifyCalendarItemViewModel = ModifyCalendarItemViewModel()
    
    func handleSwipeGesture(value: SwipeDirection) {
        self.swipeDirection = value
        switch value {
        case .left:
            self.eventList.displayDate = Calendar.current.date(byAdding: .day, value: -1, to: self.eventList.displayDate) ?? Date()
        case .right:
            self.eventList.displayDate = Calendar.current.date(byAdding: .day, value: 1, to: self.eventList.displayDate) ?? Date()
        default:
            break
        }
    }
    
    var body: some View {
        ZStack {
            // Primary Display
            VStack {
                MainHeader(for: self.date)
                if self.isDailyGoalEnabled {
                    DailyGoalTextField(isDailyGoalFocused: self.$isDailyGoalFocused)
                }
                Spacer()
                // Clock View todo in v2
                Divider()
                EventsAndRemindersMainList()
                    .environmentObject(self.addEventViewModel)
                    .gesture(DragGesture()
                                .onEnded { value in
                        withAnimation {
                            self.handleSwipeGesture(value: value.detectDirection())
                        }
                    })
            }
            .transition(.opacity)
            .ignoresSafeArea(.keyboard)
            .edgesIgnoringSafeArea(.bottom)
            // Blurred Background
            .if(self.addEventViewModel.isAddEventTextFieldFocused) { view in
                view.overlay(Color.black.opacity(0.6)
                                .blur(radius: 1))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .blur(radius: 1)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            self.addEventViewModel.isAddEventTextFieldFocused = false
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
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
