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
    
    @State private var hideClockView = false
    @FocusState private var isDailyGoalFocused: Bool
    
    
    var body: some View {
        ScrollView(.vertical) {
            MainHeader(for: self.date)
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
        if !self.isDailyGoalFocused {
            AddEventFloatingTextField()
        }
    }
}
