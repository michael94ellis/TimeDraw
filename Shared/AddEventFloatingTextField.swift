//
//  AddEventFloatingTextField.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/6/22.
//

import SwiftUI

struct AddEventFloatingTextField: View {
    
    @State var newEventName: String = ""
    @FocusState private var isNewEventFocused: Bool
    
    var body: some View {
        Group {
            HStack {
                TextField("Add an event", text: self.$newEventName)
                    .focused(self.$isNewEventFocused)
                    .submitLabel(.send)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 34)
                                    .fill(Color.lightGray2))
                Button(action: self.addEvent) {
                    Image(systemName: "plus")
                        .frame(width: 48, height: 48)
                        .background(Circle()
                                        .fill(Color.lightGray2))
                }.buttonStyle(.plain)
            }
        }
        .padding(12)
    }
    
    private func addEvent() {
        self.newEventName = ""
        self.isNewEventFocused = false
    }
}
