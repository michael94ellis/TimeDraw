//
//  RefreshControl.swift
//  TimeDraw
//
//  Created by Michael Ellis on 3/5/22.
//

import SwiftUI

struct RefreshControl: View {
    
    var coordinateSpace: CoordinateSpace
    var onRefresh: () -> Void
    @State var refresh: Bool = false
    @State var position: CGPoint = .zero
    
    var body: some View {
        GeometryReader { container in
            ZStack(alignment: .center) {
//                if self.refresh { ///show loading if refresh called
                    ProgressView()
                    .onDisappear {
                        self.onRefresh()
                        print("CC")
                    }
//                }
            }
            .frame(width: container.size.width)
        }
        .padding(.top, -50)
    }
}
