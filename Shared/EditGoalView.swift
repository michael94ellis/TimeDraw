//
//  EditGoalView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/4/22.
//

import SwiftUI

struct EditGoalView: View {
    
    @State private var goalName: String = ""
    @State private var goalDescription: String = ""
    @State private var start: Date = Date()
    @State private var end: Date = Calendar.current.date(
        byAdding: .hour,
        value: 1,
        to: Date())!
    
    var body: some View {
        NavigationView {
            VStack {
                Text("New Goal")
                Divider()
                    .padding()
                HStack {
                    Text("What's the Goal?")
                    TextField("Goal", text: self.$goalName)
                }
                HStack {
                    Text("Description:")
                    TextField("Goal Description", text: self.$goalDescription)
                }
                HStack {
                    Text("Start:")
                    DatePicker("Start", selection: self.$start)
                }
                HStack {
                    Text("End:")
                    DatePicker("Start", selection: self.$end)
                }
            }
        }
    }
}
