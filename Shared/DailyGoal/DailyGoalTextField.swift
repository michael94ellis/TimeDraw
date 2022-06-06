//
//  DailyGoalTextField.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/5/22.
//

import SwiftUI
import EventKit

struct DailyGoalTextField: View {
    
    @AppStorage("DailyGoal") private var dailyGoal: String = "What is your goal today?"
    var isDailyGoalFocused: FocusState<Bool>.Binding
    // Placeholder line limit - this feature looks ugly with > 3 lines
    @State var goalLineLimit = 3
    
    var body: some View {
        MultilineTextField("What is your goal today?", text: self.$dailyGoal, focus: self.isDailyGoalFocused, lineLimit: self.$goalLineLimit)
            .font(.callout)
            .foregroundColor(Color.gray1)
            .multilineTextAlignment(.center)
            .submitLabel(.done)
            .focused(self.isDailyGoalFocused)
            .frame(maxHeight: 70)
            .clipped()
            .background(RoundedRectangle(cornerRadius: 4).stroke(self.isDailyGoalFocused.wrappedValue ? Color.lightGray : Color.clear))
            .padding(.horizontal, 30)
            .padding(.vertical, 8)
            .fixedSize(horizontal: false, vertical: true)
    }
}
