//
//  DailyGoalTextField.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/5/22.
//

import EventKit
import DesignToken
import SwiftUI

public struct DailyGoalTextField: View {
    
    @AppStorage("DailyGoal") private var dailyGoal: String = "What is your goal today?"
    var isDailyGoalFocused: FocusState<Bool>.Binding
    
    public init(isDailyGoalFocused: FocusState<Bool>.Binding) {
        self.isDailyGoalFocused = isDailyGoalFocused
    }

    public var body: some View {
        MultilineTextField("What is your goal today?", text: self.$dailyGoal, focus: self.isDailyGoalFocused)
            .font(.callout)
            .foregroundColor(Colors.placeholderText)
            .multilineTextAlignment(.center)
            .submitLabel(.done)
            .focused(self.isDailyGoalFocused)
            .frame(maxHeight: 70)
            .clipped()
            .background(RoundedRectangle(cornerRadius: CornerRadius.textFieldRadius).stroke(self.isDailyGoalFocused.wrappedValue ? Color.lightGray : Color.clear).fill(Color(uiColor: .secondarySystemGroupedBackground)))
            .padding(.horizontal, 30)
            .padding(.vertical, 8)
            .fixedSize(horizontal: false, vertical: true)
    }
}

