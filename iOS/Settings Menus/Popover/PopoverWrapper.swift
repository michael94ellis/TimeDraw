//
//  PopoverWrapper.swift
//  TimeDraw
//
//  Created by Michael Ellis on 7/12/25.
//

import SwiftUI

struct PopoverWrapper<PopoverContent: View> : UIViewControllerRepresentable {
    
    @Binding var showPopover: Bool
    var arrowDirections: UIPopoverArrowDirection
    let popoverSize: CGSize?
    let popoverContent: () -> PopoverContent
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PopoverWrapper<PopoverContent>>) -> UIPopoverWrapperViewController<PopoverContent> {
        return UIPopoverWrapperViewController(
            popoverSize: popoverSize,
            permittedArrowDirections: arrowDirections,
            popoverContent: popoverContent) {
            self.showPopover = false
        }
    }
    
    func updateUIViewController(_ viewController: UIPopoverWrapperViewController<PopoverContent>,
                                context: UIViewControllerRepresentableContext<PopoverWrapper<PopoverContent>>) {
        viewController.updateSize(popoverSize)
        
        if showPopover {
            viewController.showPopover()
        } else {
            viewController.hidePopover()
        }
    }
}
