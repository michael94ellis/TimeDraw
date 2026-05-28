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

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "target")
                .font(.body)
                .foregroundStyle(Color.blue1)
                .padding(.top, 2)

            MultilineTextField("What is your goal today?", text: $dailyGoal, focus: isDailyGoalFocused)
                .font(.interRegular)
                .foregroundStyle(Color(uiColor: .label))
                .multilineTextAlignment(.leading)
                .submitLabel(.done)
                .focused(isDailyGoalFocused)
                .frame(maxHeight: 70)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
}


struct OnboardingDailyGoalTextField: View {
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "target")
                .font(.body)
                .foregroundStyle(Color.blue1)
            Text("What is your goal today?")
                .font(.interRegular)
                .foregroundStyle(Color.gray1)
                .multilineTextAlignment(.leading)
                .frame(maxHeight: 70)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
    }
}
