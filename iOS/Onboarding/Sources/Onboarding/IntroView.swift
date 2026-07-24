//
//  IntroView.swift
//  Onboarding
//
//  Created by Michael Ellis on 9/18/22.
//

import SwiftUI

public struct IntroView<Content: View>: View {
    @ViewBuilder var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
