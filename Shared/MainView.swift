//
//  MainView.swift
//  Shared
//
//  Created by Michael Ellis on 1/2/22.
//

import SwiftUI
import CoreData

struct MainView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Goal.start, ascending: true)],
        animation: .default)
    private var goals: FetchedResults<Goal>
    
    private let date = Date()
    private let weekdayFormatter = DateFormatter()
    private let monthNameFormatter = DateFormatter()
    
    @State private var showMenuPopover = false
    @State private var hideClockView = false
    private let emptyGoalText = "What is your goal today?"
    @State private var dailyGoal: String = "What is your goal today?"
    @FocusState private var isDailyGoalFocused: Bool
    
    @State var newEventName: String = ""
    @FocusState private var isNewEventFocused: Bool
    
    init() {
        self.weekdayFormatter.dateFormat = "EEE"
        self.monthNameFormatter.dateFormat = "LLLL"
    }
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    HStack {
                        Text(self.monthNameFormatter.string(from: self.date))
                            .fontWeight(.semibold)
                            .foregroundColor(Color.red1)
                        Spacer()
                        Button(action: {
                            self.showMenuPopover.toggle()
                        }, label: {
                            Image(systemName: "ellipsis")
                                .frame(width: 40, height: 30)
                        })
                            .popover(isPresented: self.$showMenuPopover, content: {
                                PopoverLink(destination: EditGoalView(), label: { Text("New Goal") })
                                PopoverLink(destination: Text("To Do"), label: { Text("New Event") })
                            })
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 10)
                    HStack {
                        Spacer()
                        ForEach(Calendar.current.daysWithSameWeekOfYear(as: date), id: \.self) { date in
                            if Calendar.current.isDateInToday(date) {
                                VStack {
                                    Text(self.weekdayFormatter.string(from: date))
                                        .padding(.bottom, 5)
                                    Text(date.get(.day).formatted())
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color.red1)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.2)))
                            } else {
                                VStack {
                                    Text(self.weekdayFormatter.string(from: date))
                                        .foregroundColor(Color.gray2)
                                        .padding(.bottom, 5)
                                    Text(date.get(.day).formatted())
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                            }
                            Spacer()
                        }
                    }
                }
                // Goal ?? TODO make set daily goal button
                if self.dailyGoal == self.emptyGoalText {
                    Button(action: {
                        self.dailyGoal = ""
                        self.isDailyGoalFocused = true
                    }, label: {
                        Text(self.emptyGoalText)
                            .lineLimit(3)
                            .foregroundColor(Color.gray1)
                            .padding(4) // +1 for no border
                            .padding(.horizontal, 30)
                            .padding(.vertical, 10)
                    })
                        .contentShape(Rectangle())
                } else {
                    TextField("", text: self.$dailyGoal)
                        .foregroundColor(Color.gray1)
                        .lineLimit(3)
                        .multilineTextAlignment(.center)
                        .submitLabel(.done)
                        .focused(self.$isDailyGoalFocused)
                        .onSubmit {
                            if self.dailyGoal.isEmpty { self.dailyGoal = self.emptyGoalText }
                        }
                        .padding(3) // border increases padding by 1
                        .background(RoundedRectangle(cornerRadius: 4).stroke(self.isDailyGoalFocused ? Color.gray : Color.clear))
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                }
                Spacer()
                // Clock View
                if !self.hideClockView {
                    Image(systemName: "clock")
                        .resizable()
                        .frame(width: 130, height: 130)
                        .padding(25)
                }
                Button(action: {
                    self.hideClockView.toggle()
                }, label: {
                    Group {
                        if self.hideClockView {
                            Image(systemName: "chevron.down")
                                .resizable()
                                .frame(width: 20, height: 10)
                        } else {
                            Image(systemName: "chevron.up")
                                .resizable()
                                .frame(width: 20, height: 10)
                        }
                    }
                    .frame(width: 200, height: 30)
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.05)))
                })
                    .contentShape(Rectangle())
                VStack {
                    ForEach(self.goals) { item in
                        HStack {
                            Text(item.title ?? "No Title")
                                .lineLimit(2)
                                .foregroundColor(Color(uiColor: .darkGray))
                            Spacer()
                            Text(item.start?.formatted() ?? "??")
                                .lineLimit(2)
                                .foregroundColor(Color(uiColor: .darkGray))
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.15)))
                        .padding(.horizontal)
                        
                    }
                }
                Spacer()
            }
            VStack(spacing: 0) {
                Group {
                    Divider().padding(.horizontal)
                    HStack {
                        Button(action: addItem) {
                            Image(systemName: "plus")
                        }.padding(.horizontal)
                            .buttonStyle(.plain)
                        TextField("Add an event", text: self.$newEventName)
                            .focused(self.$isNewEventFocused)
                    }
                }
                .padding()
                .background(Color(uiColor: .systemBackground))
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Goal(context: self.viewContext)
            newItem.start = Date()
            newItem.title = self.newEventName
            CoreDataManager.shared.saveMainContext()
        }
    }
}
