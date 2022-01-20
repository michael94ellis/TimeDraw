//
//  EventsAndRemindersMainList.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/20/22.
//

import SwiftUI

struct EventsAndRemindersMainList: View{
    
    @ObservedObject private var eventManager: EventManager = .shared
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(EventManager.shared.events) { item in
                    HStack {
                        Text(item.title ?? "No Title")
                            .lineLimit(2)
                            .foregroundColor(Color(uiColor: .darkGray))
                        Spacer()
                        Text(item.startDate?.formatted() ?? "??")
                            .lineLimit(2)
                            .foregroundColor(Color(uiColor: .darkGray))
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.15)))
                    .padding(.horizontal)
                    
                }
                ForEach(EventManager.shared.reminders) { item in
                    HStack {
                        Text(item.title ?? "No Title")
                            .lineLimit(2)
                            .foregroundColor(Color(uiColor: .darkGray))
                        Spacer()
                        Text("??")
                            .lineLimit(2)
                            .foregroundColor(Color(uiColor: .darkGray))
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
