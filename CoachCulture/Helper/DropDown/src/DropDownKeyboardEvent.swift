//
//  DropDownKeyboardEvent.swift
//  GoTOURNEYApp
//
//  Created by Krupa Detroja on 11/12/19.
//  Copyright © 2019 Krupa Detroja. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Keyboard events
extension DropDown {
    /**
    Starts listening to keyboard events.
    Allows the drop down to display correctly when keyboard is showed.
    */
    public static func startListeningToKeyboard() {
        KeyboardListener.sharedInstance.startListeningToKeyboard()
    }

    func startListeningToKeyboard() {
        KeyboardListener.sharedInstance.startListeningToKeyboard()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardUpdate),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardUpdate),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    func stopListeningToNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardUpdate() {
        self.setNeedsUpdateConstraints()
    }
}

// MARK: - Auto dismiss
extension DropDown {

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if dismissMode == .automatic && view === dismissableView {
            cancel()
            return nil
        } else {
            return view
        }
    }

    @objc func dismissableViewTapped() {
        cancel()
    }
}

// MARK: - Actions
extension DropDown {

    /** An Objective-C alias for the show() method which converts the returned tuple into an NSDictionary.
     - returns: An NSDictionary with a value for the "canBeDisplayed" Bool,and possibly for the "offScreenHeight" Optional(CGFloat). */
    @objc(show) public func objc_show() -> NSDictionary {
        let (canBeDisplayed, offScreenHeight) = show()
        var info = [AnyHashable: Any]()
        info["canBeDisplayed"] = canBeDisplayed
        if let offScreenHeight = offScreenHeight {
            info["offScreenHeight"] = offScreenHeight
        }
        return NSDictionary(dictionary: info)
    }

    /** Shows the drop down if enough height.
    - returns: Wether it succeed and how much height is needed to display all cells at once. */
    @discardableResult public func show() -> (canBeDisplayed: Bool, offscreenHeight: CGFloat?) {
        if self == DropDown.VisibleDropDown {
            return (true, 0)
        }
        if let visibleDropDown = DropDown.VisibleDropDown {
            visibleDropDown.cancel()
        }
        willShowAction?()
        DropDown.VisibleDropDown = self
        setNeedsUpdateConstraints()
        let visibleWindow = UIWindow.visibleWindow()
        visibleWindow?.addSubview(self)
        visibleWindow?.bringSubviewToFront(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        visibleWindow?.addUniversalConstraints(format: "|[dropDown]|", views: ["dropDown": self])
        let layout = computeLayout()
        if !layout.canBeDisplayed {
            hide()
            return (layout.canBeDisplayed, layout.offscreenHeight)
        }
        isHidden = false
        tableViewContainer.transform = downScaleTransform
        UIView.animate(
            withDuration: animationduration,
            delay: 0,
            options: animationEntranceOptions,
            animations: { [unowned self] in
                self.setShowedState()
            },
            completion: nil)
        selectRow(at: selectedRowIndex)
        return (layout.canBeDisplayed, layout.offscreenHeight)
    }

    /// Hides the drop down.
    public func hide() {
        if self == DropDown.VisibleDropDown {
            /* If one drop down is showed and another one is not
            but we call `hide()` on the hidden one:
            we don't want it to set the `VisibleDropDown` to nil. */
            DropDown.VisibleDropDown = nil
        }
        if isHidden {
            return
        }
        UIView.animate(
            withDuration: animationduration,
            delay: 0,
            options: animationExitOptions,
            animations: { [unowned self] in
                self.setHiddentState()
            },
            completion: { [unowned self] _  in
                self.isHidden = true
                self.removeFromSuperview()
            })
    }

    func cancel() {
        hide()
        cancelAction?()
    }

    func setHiddentState() {
        alpha = 0
    }

    func setShowedState() {
        alpha = 1
        tableViewContainer.transform = CGAffineTransform.identity
    }

}
