//
//  EventsAndRemindersMainList.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/20/22.
//

import SwiftUI

struct EventsAndRemindersMainList: View{
    
    @ObservedObject private var eventManager: EventManager = .shared
    
    private let timeOnly = DateFormatter()
    
    init() {
        self.timeOnly.dateFormat = "hh:mma"
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(EventManager.shared.events) { item in
                    HStack {
                        Circle().fill(Color(cgColor: item.calendar.cgColor))
                            .frame(width: 8, height: 8)
                        Text(item.title ?? "No Title")
                            .lineLimit(2)
                            .foregroundColor(Color(uiColor: .darkGray))
                        Spacer()
                        Text("\(self.timeOnly.string(from: item.startDate)) - \(self.timeOnly.string(from: item.startDate))")
                         .font(.caption)
                         .foregroundColor(Color(uiColor: .darkGray))
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.15)))
                    .padding(.horizontal)
                    
                }
                ForEach(EventManager.shared.reminders) { item in
                    HStack {
                        Circle().fill(Color(cgColor: item.calendar.cgColor))
                            .frame(width: 8, height: 8)
                        Text(item.title ?? "No Title")
                            .lineLimit(2)
                            .foregroundColor(Color(uiColor: .darkGray))
                        Spacer()
                        if item.priority > 0 {
                            Text("Priority: \(item.priority)")
                                .font(.caption)
                                .foregroundColor(Color(uiColor: .darkGray))
                        }
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.15)))
                    .padding(.horizontal)
                    
                }
                Spacer(minLength: 120)
            }
        }
    }
}
