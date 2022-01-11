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
        sortDescriptors: [NSSortDescriptor(keyPath: \DailyGoal.date, ascending: true)],
        animation: .default)
    private var dailyGoals: FetchedResults<DailyGoal>
    
    private let date = Date()
    private let weekdayFormatter = DateFormatter()
    private let monthNameFormatter = DateFormatter()
    
    @State private var showMenuPopover = false
    @State private var hideClockView = false
    @FocusState private var isDailyGoalFocused: Bool
    
    @State var newEventName: String = ""
    @FocusState private var isNewEventFocused: Bool
    
    init() {
        self.weekdayFormatter.dateFormat = "EEE"
        self.monthNameFormatter.dateFormat = "LLLL"
//        let goal: DailyGoal? = dailyGoals.first(where: {
//            if let dailyGoalDate = $0.date,
//               Calendar.current.isDateInToday(dailyGoalDate) {
//                return true
//            }
//            return false
//        })
//        if let todaysDailyGoal = goal {
//            self.dailyGoal = todaysDailyGoal.text ?? self.emptyGoalText
//        }
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
//                            self.showMenuPopover.toggle()
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
                DailyGoalTextField(isDailyGoalFocused: self.$isDailyGoalFocused)
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
                    Text("Events List TODO/FIXME")
                    // TODO: Event List
//                    ForEach(self.) { item in
//                        HStack {
//                            Text(item.title ?? "No Title")
//                                .lineLimit(2)
//                                .foregroundColor(Color(uiColor: .darkGray))
//                            Spacer()
//                            Text(item.start?.formatted() ?? "??")
//                                .lineLimit(2)
//                                .foregroundColor(Color(uiColor: .darkGray))
//                        }
//                        .padding(.vertical, 6)
//                        .padding(.horizontal)
//                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.15)))
//                        .padding(.horizontal)
//
//                    }
                }
                Spacer()
            }
            if self.isDailyGoalFocused {
                // TODO: Something for this?
            } else {
                VStack(spacing: 0) {
                    Group {
                        Divider().padding(.horizontal)
                        HStack {
                            Button(action: self.addEvent) {
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
    }
    
    private func addEvent() {
        withAnimation {
            // TODO: Add Event
        }
    }
    
    private func addDailyGoal() {
        withAnimation {
            let newItem = DailyGoal(context: self.viewContext)
            newItem.date = Date()
            newItem.text = self.newEventName
            CoreDataManager.shared.saveMainContext()
        }
    }
}
