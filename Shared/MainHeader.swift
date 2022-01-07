//
//  MainHeader.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/6/22.
//

import SwiftUI

struct MainHeader: View {
    
    @State private var showMenuPopover = false

    private let date: Date
    private let weekdayFormatter = DateFormatter()
    private let monthNameFormatter = DateFormatter()
    
    init(for date: Date) {
        self.date = date
        self.weekdayFormatter.dateFormat = "EEE"
        self.monthNameFormatter.dateFormat = "LLLL"
    }
    
    var body: some View {
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
                Menu(content: {
                    Button("Cancel", action: { })
                    Button("Cance2l", action: { })
                }, label: { Image(systemName: "ellipses") })
        
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
                        .frame(maxWidth: 45)
                        .padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.2)))
                    } else {
                        VStack {
                            Text(self.weekdayFormatter.string(from: date))
                                .foregroundColor(Color.gray2)
                                .padding(.bottom, 5)
                            Text(date.get(.day).formatted())
                        }
                        .frame(maxWidth: 45)
                        .padding(.vertical, 10)
                    }
                    Spacer()
                }
            }
        }
    }
}
