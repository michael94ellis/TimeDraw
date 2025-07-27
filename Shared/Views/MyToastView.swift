//
//  MyToastView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 7/26/25.
//

import SwiftUI

struct MyToastView: View {
    @State var message: String
    let bgColor: Color
    let duration: TimeInterval
    let animationDuration: TimeInterval
    
    @State private var isVisible = false
    @State private var offsetY: CGFloat
    
    init(message: String,
         duration: TimeInterval = 2.6,
         animationDuration: TimeInterval = 0.3,
         bgColor: Color = .gray) {
        self.message = message
        self.duration = duration
        self.animationDuration = animationDuration
        self.bgColor = bgColor
        self.offsetY = 50
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text(message)
                .padding()
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .background(bgColor)
                .foregroundColor(.white)
                .cornerRadius(8)
                .opacity(isVisible ? 1 : 0)
                .offset(y: offsetY)
                .onAppear {
                    withAnimation(.easeInOut(duration: animationDuration)) {
                        offsetY = 0
                        isVisible = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + (duration - animationDuration)) {
                        withAnimation(.easeInOut(duration: animationDuration)) {
                            offsetY = 50
                            isVisible = false
                        }
                    }
                }
        }
        .padding(.horizontal, 24)
    }
}

