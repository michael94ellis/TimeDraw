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
    
    /// If the string has more characters than components(separated by newline) than we must perform validation through char search
    private func performStringSearchByChar() {
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
    
    /// The more efficient way to search the string for newline characters
    private func performSearchByComponents(_ dailyGoalComponents: [String.SubSequence]) {
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
    
    private func addDailyGoal() {
//        let formatter = DateFormatter()
//        formatter.timeStyle = .none
//        formatter.dateStyle = .full
//        formatter.timeZone = TimeZone.current
//        print(formatter.string(from: Date().onlyDate))
//        let newItem = DailyGoal(context: self.viewContext)
//        newItem.date = Date()
//        newItem.text = self.newEventName
//        CoreDataManager.shared.saveMainContext()
    }
    
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
                // If there are more characters than components the user has added back-to-back newlines
                if dailyGoalComponents.count < newDailyGoal.count {
                    performStringSearchByChar()
                    return
                } else if dailyGoalComponents.count - 1 >= 2 {
                    // If theres 3 or more newline characters that is 4+ lines of text
                    performSearchByComponents(dailyGoalComponents)
                }
            })
            .frame(maxHeight: 70)
            .clipped()
            .background(RoundedRectangle(cornerRadius: 4).stroke(self.isDailyGoalFocused.wrappedValue ? Color.lightGray : Color.clear))
            .padding(.horizontal, 30)
            .padding(.vertical, 8)
            .fixedSize(horizontal: false, vertical: true)
    }
}
