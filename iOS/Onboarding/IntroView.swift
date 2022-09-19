//
//  IntroView.swift
//  TimeDraw
//
//  Created by Michael Ellis on 9/18/22.
//

import SwiftUI

struct IntroView<Content: View>: View {
    @ViewBuilder var content: Content
        
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Spacer()
                content
                Spacer()
            }
            Spacer()
        }
        .background(.background)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
