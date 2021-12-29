//
//  DropDownSetup.swift
//  GoTOURNEYApp
//
//  Created by Krupa Detroja on 11/12/19.
//  Copyright © 2019 Krupa Detroja. All rights reserved.
//

import Foundation
import UIKit

public typealias ComputeLayoutTuple = (x: CGFloat, y: CGFloat, width: CGFloat, offscreenHeight: CGFloat)

// MARK: - Setup
extension DropDown {

    func setup() {
        tableView.register(cellNib, forCellReuseIdentifier: DPDConstant.ReusableIdentifier.DropDownCell)
        DispatchQueue.main.async {
            self.updateConstraintsIfNeeded()
            self.setupUI()
        }
        dismissMode = .onTap
        tableView.delegate = self
        tableView.dataSource = self
        startListeningToKeyboard()
        accessibilityIdentifier = "drop_down"
    }

    func setupUI() {
        super.backgroundColor = .clear
        tableViewContainer.layer.masksToBounds = false
        tableViewContainer.layer.cornerRadius = cornerRadius
        tableViewContainer.layer.shadowColor = shadowColor.cgColor
        tableViewContainer.layer.shadowOffset = shadowOffset
        tableViewContainer.layer.shadowOpacity = shadowOpacity
        tableViewContainer.layer.shadowRadius = shadowRadius
        tableView.rowHeight = cellHeight
        tableView.backgroundColor = tableViewBackgroundColor
        tableView.separatorColor = separatorColor
        tableView.layer.cornerRadius = cornerRadius
        tableView.layer.masksToBounds = true
        setHiddentState()
        isHidden = true
    }
}

// MARK: - UI
extension DropDown {

    public override func updateConstraints() {
        if !didSetupConstraints {
            setupConstraints()
        }
        didSetupConstraints = true
        let layout = computeLayout()
        if !layout.canBeDisplayed {
            super.updateConstraints()
            hide()
            return
        }
        xConstraint.constant = layout.x
        yConstraint.constant = layout.y
        widthConstraint.constant = layout.width
        heightConstraint.constant = layout.visibleHeight
        tableView.isScrollEnabled = layout.offscreenHeight > 0
        super.updateConstraints()
    }

    func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(dismissableView)
        dismissableView.translatesAutoresizingMaskIntoConstraints = false
        addUniversalConstraints(format: "|[dismissableView]|", views: ["dismissableView": dismissableView])
        addSubview(tableViewContainer)
        tableViewContainer.translatesAutoresizingMaskIntoConstraints = false
        xConstraint = NSLayoutConstraint(item: tableViewContainer, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        addConstraint(xConstraint)
        yConstraint = NSLayoutConstraint(item: tableViewContainer, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        addConstraint(yConstraint)
        widthConstraint = NSLayoutConstraint(item: tableViewContainer, attribute: .width, relatedBy: .equal, toItem: nil,
            attribute: .notAnAttribute, multiplier: 1, constant: 0)
        tableViewContainer.addConstraint(widthConstraint)
        heightConstraint = NSLayoutConstraint(item: tableViewContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        tableViewContainer.addConstraint(heightConstraint)
        // Table view
        tableViewContainer.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableViewContainer.addUniversalConstraints(format: "|[tableView]|", views: ["tableView": tableView])
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsUpdateConstraints()
        let shadowPath = UIBezierPath(roundedRect: tableViewContainer.bounds, cornerRadius: DPDConstant.UI.CornerRadius)
        tableViewContainer.layer.shadowPath = shadowPath.cgPath
    }

    func computeLayout() -> (x: CGFloat, y: CGFloat, width: CGFloat, offscreenHeight: CGFloat, visibleHeight: CGFloat, canBeDisplayed: Bool, Direction: Direction) {
        var layout: ComputeLayoutTuple = (0, 0, 0, 0)
        var direction = self.direction
        guard let window = UIWindow.visibleWindow() else { return (0, 0, 0, 0, 0, false, direction) }
        barButtonItemCondition: if let anchorView = anchorView as? UIBarButtonItem {
            let isRightBarButtonItem = anchorView.plainView.frame.minX > window.frame.midX
            guard isRightBarButtonItem else { break barButtonItemCondition }
            let width = self.width ?? fittingWidth()
            let anchorViewWidth = anchorView.plainView.frame.width
            let x = -(width - anchorViewWidth)
            bottomOffset = CGPoint(x: x, y: 0)
        }
        if anchorView == nil {
            layout = computeLayoutBottomDisplay(window: window)
            direction = .any
        } else {
            switch direction {
            case .any:
                layout = computeLayoutBottomDisplay(window: window)
                direction = .bottom

                if layout.offscreenHeight > 0 {
                    let topLayout = computeLayoutForTopDisplay(window: window)

                    if topLayout.offscreenHeight < layout.offscreenHeight {
                        layout = topLayout
                        direction = .top
                    }
                }
            case .bottom:
                layout = computeLayoutBottomDisplay(window: window)
                direction = .bottom
            case .top:
                layout = computeLayoutForTopDisplay(window: window)
                direction = .top
            }
        }
        constraintWidthToFittingSizeIfNecessary(layout: &layout)
        constraintWidthToBoundsIfNecessary(layout: &layout, in: window)
        let visibleHeight = tableHeight - layout.offscreenHeight
        let canBeDisplayed = visibleHeight >= minHeight
        return (layout.x, layout.y, layout.width, layout.offscreenHeight, visibleHeight, canBeDisplayed, direction)
    }

    func computeLayoutBottomDisplay(window: UIWindow) -> ComputeLayoutTuple {
        var offscreenHeight: CGFloat = 0
        let width = self.width ?? (anchorView?.plainView.bounds.width ?? fittingWidth()) - bottomOffset.x
        let anchorViewX = anchorView?.plainView.windowFrame?.minX ?? window.frame.midX - (width / 2)
        let anchorViewY = anchorView?.plainView.windowFrame?.minY ?? window.frame.midY - (tableHeight / 2)
        let x = anchorViewX + bottomOffset.x
        let y = anchorViewY + bottomOffset.y
        let maxY = y + tableHeight
        let windowMaxY = window.bounds.maxY - DPDConstant.UI.HeightPadding
        let keyboardListener = KeyboardListener.sharedInstance
        let keyboardMinY = keyboardListener.keyboardFrame.minY - DPDConstant.UI.HeightPadding
        if keyboardListener.isVisible && maxY > keyboardMinY {
            offscreenHeight = abs(maxY - keyboardMinY)
        } else if maxY > windowMaxY {
            offscreenHeight = abs(maxY - windowMaxY)
        }
        return (x, y, width, offscreenHeight)
    }

    func computeLayoutForTopDisplay(window: UIWindow) -> ComputeLayoutTuple {
        var offscreenHeight: CGFloat = 0
        let anchorViewX = anchorView?.plainView.windowFrame?.minX ?? 0
        let anchorViewMaxY = anchorView?.plainView.windowFrame?.maxY ?? 0
        let x = anchorViewX + topOffset.x
        var y = (anchorViewMaxY + topOffset.y) - tableHeight
        let windowY = window.bounds.minY + DPDConstant.UI.HeightPadding
        if y < windowY {
            offscreenHeight = abs(y - windowY)
            y = windowY
        }
        let width = self.width ?? (anchorView?.plainView.bounds.width ?? fittingWidth()) - topOffset.x
        return (x, y, width, offscreenHeight)
    }

    func fittingWidth() -> CGFloat {
        if templateCell == nil {
            templateCell = cellNib.instantiate(withOwner: nil, options: nil)[0] as? DropDownCell
        }
        var maxWidth: CGFloat = 0
        for index in 0..<dataSource.count {
            configureCell(templateCell, at: index)
            templateCell.bounds.size.height = cellHeight
            let width = templateCell.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).width
            if width > maxWidth {
                maxWidth = width
            }
        }
        return maxWidth
    }

    func constraintWidthToBoundsIfNecessary(layout: inout ComputeLayoutTuple, in window: UIWindow) {
        let windowMaxX = window.bounds.maxX
        let maxX = layout.x + layout.width
        if maxX > windowMaxX {
            let delta = maxX - windowMaxX
            let newOrigin = layout.x - delta
            if newOrigin > 0 {
                layout.x = newOrigin
            } else {
                layout.x = 0
                layout.width += newOrigin // newOrigin is negative,so this operation is a substraction
            }
        }
    }

    func constraintWidthToFittingSizeIfNecessary(layout: inout ComputeLayoutTuple) {
        guard width == nil else { return }
        if layout.width < fittingWidth() {
            layout.width = fittingWidth()
        }
    }
}
