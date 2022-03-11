//
//  DailyGoalTextField.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/5/22.
//

import SwiftUI

struct DailyGoalTextField: View {
    
    @AppStorage("DailyGoal") private var dailyGoal: String = "What is your goal today?"
    var isDailyGoalFocused: FocusState<Bool>.Binding
    
    var body: some View {
        MultilineTextField("What is your goal today?", text: self.$dailyGoal, focus: self.isDailyGoalFocused)
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
