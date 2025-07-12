//
//  UIPopoverWrapperViewController.swift
//  TimeDraw
//
//  Created by Michael Ellis on 7/12/25.
//

import SwiftUI

class UIPopoverWrapperViewController<PopoverContent: View>: UIViewController, UIPopoverPresentationControllerDelegate {
    
    var popoverSize: CGSize?
    let permittedArrowDirections: UIPopoverArrowDirection
    let popoverContent: () -> PopoverContent
    let onDismiss: () -> Void
    
    var popoverVC: UIViewController?
    
    required init?(coder: NSCoder) { fatalError("") }
    init(popoverSize: CGSize?,
         permittedArrowDirections: UIPopoverArrowDirection,
         popoverContent: @escaping () -> PopoverContent,
         onDismiss: @escaping() -> Void) {
        self.popoverSize = popoverSize
        self.permittedArrowDirections = permittedArrowDirections
        self.popoverContent = popoverContent
        self.onDismiss = onDismiss
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none // this is what forces popovers on iPhone
    }
    
    func showPopover() {
        guard popoverVC == nil else { return }
        let hostingViewController = UIHostingController(rootView: popoverContent())
        if let size = popoverSize { hostingViewController.preferredContentSize = size }
        hostingViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        if let popover = hostingViewController.popoverPresentationController {
            popover.sourceView = view
            popover.permittedArrowDirections = self.permittedArrowDirections
            popover.delegate = self
        }
        popoverVC = hostingViewController
        self.present(hostingViewController, animated: true, completion: nil)
    }
    
    func hidePopover() {
        guard let vc = popoverVC, !vc.isBeingDismissed else { return }
        vc.dismiss(animated: true, completion: nil)
        popoverVC = nil
    }
    
    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        popoverVC = nil
        self.onDismiss()
    }
    
    func updateSize(_ size: CGSize?) {
        self.popoverSize = size
        if let viewController = popoverVC, let size = size {
            viewController.preferredContentSize = size
        }
    }
}
