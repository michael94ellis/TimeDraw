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
    @State var showClockView: Bool = true
    @FocusState private var isDailyGoalFocused: Bool
    @AppStorage("isDailyGoalEnabled") var isDailyGoalEnabled: Bool = true
    @AppStorage("isTimeDrawClockEnabled") var isTimeDrawClockEnabled: Bool = true
    @ObservedObject private var eventList: EventListViewModel = .shared
    @State var swipeDirection: SwipeDirection = .left
    
    @StateObject private var addEventViewModel: ModifyCalendarItemViewModel = ModifyCalendarItemViewModel()
    
    var body: some View {
        ZStack {
            // Primary Display
            VStack {
                MainHeader()
                if self.isDailyGoalEnabled {
                    DailyGoalTextField(isDailyGoalFocused: self.$isDailyGoalFocused)
                }
                Spacer()
                if self.isTimeDrawClockEnabled {
                    if self.showClockView {
                        TimeDrawClock()
                            .gesture(DragGesture().onEnded({ value in
                                let direction = value.detectDirection()
                                if direction == .down || direction == .up {
                                    withAnimation {
                                        self.showClockView.toggle()
                                    }
                                }
                            }))
                    }
                    Button(action: {
                        withAnimation {
                            self.showClockView.toggle()
                        }
                    }) {
                        Image(systemName: self.showClockView ? "chevron.up" : "chevron.down")
                    }
                    .frame(height: 35)
                }
                // Clock View todo in v2
                Divider()
                EventsAndRemindersMainList()
                    .environmentObject(self.addEventViewModel)
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
                    .padding(.bottom, 16)
            }
        }
    }
}
