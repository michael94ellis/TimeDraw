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
    private let date = Date()
    private let weekdayFormatter = DateFormatter()
    private let monthNameFormatter = DateFormatter()
    
    init() {
        self.weekdayFormatter.dateFormat = "EEE"
        self.monthNameFormatter.dateFormat = "LLLL"
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                HStack {
                    Text(self.monthNameFormatter.string(from: self.date))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.red1)
                    Spacer()
                    Button(action: {
                        print("Menu Button Pressed")
                    }, label: {
                        Image(systemName: "ellipsis")
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
                                Spacer()
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
                                Spacer()
                                Text(date.get(.day).formatted())
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                        }
                        Spacer()
                    }
                }
                Spacer()
                Text("What is your goal today?")
                    .foregroundColor(Color.gray1)
                Spacer()
            }
        }
    }
}
