//
//  DropDown.swift
//  DropDown
//
// GoLeagueMembers
//  Created by Krupa Detroja on 04/02/19.
//  Copyright © 2017 Krupa Detroja. All rights reserved.

import UIKit

public typealias Index = Int
public typealias Closure = () -> Void
public typealias SelectionClosure = (Index, String) -> Void
public typealias ConfigurationClosure = (Index, String) -> String
public typealias CellConfigurationClosure = (Index, String, DropDownCell) -> Void

/// Can be `UIView` or `UIBarButtonItem`.
@objc public protocol AnchorView: class {

	var plainView: UIView { get }
}

extension UIView: AnchorView {

	public var plainView: UIView {
		return self
	}
}

extension UIBarButtonItem: AnchorView {

	public var plainView: UIView {
		return value(forKey: "view") as? UIView ?? UIView()
	}
}

/// A Material Design drop down in replacement for `UIPickerView`.
public final class DropDown: UIView {
	/// The dismiss mode for a drop down.
	public enum DismissMode {
		case onTap /// A tap outside the drop down is required to dismiss.
        case automatic /// No tap is required to dismiss,it will dimiss when interacting with anything else.
        case manual /// Not dismissable by the user.
	}
	/// The direction where the drop down will show from the `anchorView`.
	public enum Direction {
        case any /// Not dismissable by the user.
        case top /// The drop down will show above the anchor view or will not be showed if not enough space.
        case bottom /// The drop down will show above the anchor view or will not be showed if not enough space.
	}
	// MARK: - Properties
	/// The current visible drop down. There can be only one visible drop down at a time.
	public static weak var VisibleDropDown: DropDown?
	// MARK: - UI
    let dismissableView = UIView()
	let tableViewContainer = UIView()
	let tableView = UITableView()
	var templateCell: DropDownCell!
	/// The view to which the drop down will displayed onto.
	public weak var anchorView: AnchorView? {
		didSet { setNeedsUpdateConstraints() }
	}
	/** The possible directions where the drop down will be showed. See `Direction` enum for more info. */
	public var direction = Direction.any
	/** The offset point relative to `anchorView` when the drop down is shown above the anchor view. By default,the drop down is showed onto the `anchorView` with the top left corner for its origin,so an offset equal to (0,0). You can change here the default drop down origin. */
	public var topOffset: CGPoint = .zero {
		didSet { setNeedsUpdateConstraints() }
	}
	/** The offset point relative to `anchorView` when the drop down is shown below the anchor view. By default,the drop down is showed onto the `anchorView` with the top left corner for its origin,so an offset equal to (0,0). You can change here the default drop down origin. */
	public var bottomOffset: CGPoint = .zero {
		didSet { setNeedsUpdateConstraints() }
	}
	/** The width of the drop down. Defaults to `anchorView.bounds.width - offset.x`. */
    public  var width: CGFloat? {
		didSet { setNeedsUpdateConstraints() }
	}
	// MARK: - Constraints
	var heightConstraint: NSLayoutConstraint!
	var widthConstraint: NSLayoutConstraint!
	var xConstraint: NSLayoutConstraint!
	var yConstraint: NSLayoutConstraint!
	// MARK: - Appearance
	@objc public dynamic var cellHeight = DPDConstant.UI.RowHeight {
		willSet { tableView.rowHeight = newValue }
		didSet { reloadAllComponents() }
	}
	@objc public dynamic var tableViewBackgroundColor = DPDConstant.UI.BackgroundColor {
		willSet { tableView.backgroundColor = newValue }
	}
	public override var backgroundColor: UIColor? {
		get { return tableViewBackgroundColor }
		set { tableViewBackgroundColor = newValue! }
	}
	/** The background color of the selected cell in the drop down.
	Changing the background color automatically reloads the drop down. */
	@objc public dynamic var selectionBackgroundColor = DPDConstant.UI.SelectionBackgroundColor
	/** The separator color between cells.
	Changing the separator color automatically reloads the drop down. */
	@objc public dynamic var separatorColor = DPDConstant.UI.SeparatorColor {
		willSet { tableView.separatorColor = newValue }
		didSet { reloadAllComponents() }
	}
	/** The corner radius of DropDown.
     Changing the corner radius automatically reloads the drop down. */
	@objc public dynamic var cornerRadius = DPDConstant.UI.CornerRadius {
		willSet {
			tableViewContainer.layer.cornerRadius = newValue
			tableView.layer.cornerRadius = newValue
		}
		didSet { reloadAllComponents() }
	}
	/** The color of the shadow.
	Changing the shadow color automatically reloads the drop down. */
	@objc public dynamic var shadowColor = DPDConstant.UI.Shadow.Color {
		willSet { tableViewContainer.layer.shadowColor = newValue.cgColor }
		didSet { reloadAllComponents() }
	}
	/** The offset of the shadow.
	Changing the shadow color automatically reloads the drop down. */
	@objc public dynamic var shadowOffset = DPDConstant.UI.Shadow.Offset {
		willSet { tableViewContainer.layer.shadowOffset = newValue }
		didSet { reloadAllComponents() }
	}
	/** The opacity of the shadow.
	Changing the shadow opacity automatically reloads the drop down. */
	@objc public dynamic var shadowOpacity = DPDConstant.UI.Shadow.Opacity {
		willSet { tableViewContainer.layer.shadowOpacity = newValue }
		didSet { reloadAllComponents() }
	}
	/** The radius of the shadow. Changing the shadow radius automatically reloads the drop down. */
	@objc public dynamic var shadowRadius = DPDConstant.UI.Shadow.Radius {
		willSet { tableViewContainer.layer.shadowRadius = newValue }
		didSet { reloadAllComponents() }
	}
	/** The duration of the show/hide animation. */
	@objc public dynamic var animationduration = DPDConstant.Animation.Duration
	/** The option of the show animation. Global change. */
	public static var animationEntranceOptions = DPDConstant.Animation.EntranceOptions
	/** The option of the hide animation. Global change. */
	public static var animationExitOptions = DPDConstant.Animation.ExitOptions
	/** The option of the show animation. Only change the caller. To change all drop down's use the static var. */
    public var animationEntranceOptions: UIView.AnimationOptions = DropDown.animationEntranceOptions
	/** The option of the hide animation. Only change the caller. To change all drop down's use the static var. */
    public var animationExitOptions: UIView.AnimationOptions = DropDown.animationExitOptions
	/** The downScale transformation of the tableview when the DropDown is appearing */
	public var downScaleTransform = DPDConstant.Animation.DownScaleTransform {
		willSet { tableViewContainer.transform = newValue }
	}
	/** The color of the text for each cells of the drop down.
	Changing the text color automatically reloads the drop down. */
	@objc public dynamic var textColor = DPDConstant.UI.TextColor {
		didSet { reloadAllComponents() }
	}
	/** The font of the text for each cells of the drop down.
	Changing the text font automatically reloads the drop down. */
	@objc public dynamic var textFont = DPDConstant.UI.TextFont {
		didSet { reloadAllComponents() }
	}
    /** The NIB to use for DropDownCells
    Changing the cell nib automatically reloads the drop down. */
	public var cellNib = UINib(nibName: "DropDownCell", bundle: Bundle(for: DropDownCell.self)) {
		didSet {
			tableView.register(cellNib, forCellReuseIdentifier: DPDConstant.ReusableIdentifier.DropDownCell)
			templateCell = nil
			reloadAllComponents()
		}
	}
	// MARK: Content
	/** The data source for the drop down.
	Changing the data source automatically reloads the drop down. */
	public var dataSource = [String]() {
		didSet {
			deselectRow(at: selectedRowIndex)
			reloadAllComponents()
		}
	}
	/** The localization keys for the data source for the drop down. Changing this value automatically reloads the drop down. This has uses for setting accibility identifiers on the drop down cells (same ones as the localization keys). */
	public var localizationKeysDataSource = [String]() {
		didSet {
			dataSource = localizationKeysDataSource.map { NSLocalizedString($0, comment: "") }
		}
	}
	/// The index of the row after its seleciton.
	var selectedRowIndex: Index?
	/** The format for the cells' text. By default,the cell's text takes the plain `dataSource` value. Changing `cellConfiguration` automatically reloads the drop down. */
	public var cellConfiguration: ConfigurationClosure? {
		didSet { reloadAllComponents() }
	}
    /** A advanced formatter for the cells. Allows customization when custom cells are used Changing `customCellConfiguration` automatically reloads the drop down. */
    public var customCellConfiguration: CellConfigurationClosure? {
        didSet { reloadAllComponents() }
    }
	/// The action to execute when the user selects a cell.
	public var selectionAction: SelectionClosure?
	/// The action to execute when the drop down will show.
	public var willShowAction: Closure?
	/// The action to execute when the user cancels/hides the drop down.
	public var cancelAction: Closure?
	/// The dismiss mode of the drop down. Default is `OnTap`.
	public var dismissMode = DismissMode.onTap {
		willSet {
			if newValue == .onTap {
				let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissableViewTapped))
				dismissableView.addGestureRecognizer(gestureRecognizer)
			} else if let gestureRecognizer = dismissableView.gestureRecognizers?.first {
				dismissableView.removeGestureRecognizer(gestureRecognizer)
			}
		}
	}
	var minHeight: CGFloat {
		return tableView.rowHeight
	}
	var didSetupConstraints = false

	// MARK: - Init's
	deinit {
		stopListeningToNotifications()
	}
	/** Creates a new instance of a drop down. Don't forget to setup the `dataSource`, the `anchorView` and the `selectionAction` at least before calling `show()`. */
	public convenience init() {
		self.init(frame: .zero)
	}

	public convenience init(anchorView: AnchorView, selectionAction: SelectionClosure? = nil, dataSource: [String] = [], topOffset: CGPoint? = nil, bottomOffset: CGPoint? = nil, cellConfiguration: ConfigurationClosure? = nil, cancelAction: Closure? = nil) {
		self.init(frame: .zero)
		self.anchorView = anchorView
		self.selectionAction = selectionAction
		self.dataSource = dataSource
		self.topOffset = topOffset ?? .zero
		self.bottomOffset = bottomOffset ?? .zero
		self.cellConfiguration = cellConfiguration
		self.cancelAction = cancelAction
	}

	override public init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}
}
