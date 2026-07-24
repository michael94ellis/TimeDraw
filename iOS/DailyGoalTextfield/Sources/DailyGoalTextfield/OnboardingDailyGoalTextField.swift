//
//  OnboardingDailyGoalTextField.swift
//  DailyGoalTextfield
//
//  Created by Michael Ellis on 7/21/26.
//

import DesignToken
import SwiftUI

public struct OnboardingDailyGoalTextField: View {
    
    public init() { }
    
    public var body: some View {
        Text("What is your goal today?")
            .font(.app(.body))
            .foregroundColor(Colors.placeholderText)
            .multilineTextAlignment(.center)
            .frame(maxHeight: 70)
            .clipped()
            .background(RoundedRectangle(cornerRadius: CornerRadius.textFieldRadius).stroke(Color.clear))
            .padding(.horizontal, 30)
            .padding(.vertical, 8)
            .fixedSize(horizontal: false, vertical: true)
    }
}
