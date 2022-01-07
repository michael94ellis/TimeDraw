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
                HStack {
                    Button(action: self.addEvent) {
                        Image("smile.face")
                            .resizable()
                            .frame(width: 22, height: 22)
                    }.buttonStyle(.plain)
                        .frame(width: 36, height: 36)
                    
                    TextField("", text: self.$newEventName)
                        .focused(self.$isNewEventFocused)
                        .submitLabel(.send)
                        .foregroundColor(Color.dark)
                        .placeholder(when: self.newEventName.isEmpty) {
                            Text("Event").foregroundColor(.gray)
                        }
                }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 34)
                                    .fill(Color(uiColor: .systemGray6)))
                Button(action: self.addEvent) {
                    Image(systemName: "plus")
                        .frame(width: 48, height: 48)
                        .foregroundColor(Color.white)
                        .background(Circle()
                                        .fill(Color.darkGray2))
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
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}
