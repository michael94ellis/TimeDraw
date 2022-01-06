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
            .foregroundColor(Color.gray1)
            .multilineTextAlignment(.center)
            .submitLabel(.done)
            .focused(self.isDailyGoalFocused)
            .onChange(of: self.dailyGoal, perform: { newDailyGoal in
                // Count of newlines = split by newline count - 1
                // No need to check every character for `Character.isNewline`
                let dailyGoalComponents = newDailyGoal.split(separator: "\n")
                if dailyGoalComponents.count < newDailyGoal.count {
                    var totalNewLines = 0
                    // Remove newline characters that are not the first or second newline character
                    var newDailyGoalWithoutLastNewlines = ""
                    dailyGoal.forEach {
                        if $0.isNewline {
                            totalNewLines += 1
                            if totalNewLines <= 2 {
                                newDailyGoalWithoutLastNewlines.append($0)
                            } else {
                                return
                            }
                        } else {
                            newDailyGoalWithoutLastNewlines.append($0)
                        }
                    }
                    self.dailyGoal = newDailyGoalWithoutLastNewlines
                }
                // If theres 3 or more newline characters that is 4+ lines of text
                if dailyGoalComponents.count - 1 >= 2 {
                    // Remove newline characters that are not the first or second newline character
                    var newDailyGoalWithoutLastNewlines = ""
                    for index in dailyGoalComponents.indices {
                        newDailyGoalWithoutLastNewlines.append(contentsOf: dailyGoalComponents[index])
                        if index < 2 {
                            newDailyGoalWithoutLastNewlines.append(contentsOf: "\n")
                        }
                    }
                    // Replace the daily goal with the new appropriate number of lines daily goal
                    self.dailyGoal = newDailyGoalWithoutLastNewlines
                }
            })
            .frame(maxHeight: 70)
            .clipped()
            .background(RoundedRectangle(cornerRadius: 4).stroke(self.isDailyGoalFocused.wrappedValue ? Color.lightGrey : Color.clear))
            .padding(.horizontal, 30)
            .padding(.vertical, 8)
            .fixedSize(horizontal: false, vertical: true)
    }
}
