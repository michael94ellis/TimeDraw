//
//  PopoverButton.swift
//  TimeDraw
//
//  Created by Michael Ellis on 1/22/22.
//

import Foundation
import SwiftUI

struct PopoverButton<Content: View, PopoverContent: View>: View {
    
    @Binding var showPopover: Bool
    var popoverSize: CGSize? = nil
    var arrowDirections: UIPopoverArrowDirection = [.down]
    let content: () -> Content
    let popoverContent: () -> PopoverContent
    
    var body: some View {
        content()
            .background(
                PopoverWrapper(showPopover: $showPopover, arrowDirections: arrowDirections, popoverSize: popoverSize, popoverContent: popoverContent)
            )
    }
}
