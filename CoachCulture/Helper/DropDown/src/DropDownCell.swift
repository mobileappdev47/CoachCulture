//
//  DropDownCellTableViewCell.swift
//  DropDown
//
// GoLeagueMembers
//  Created by Krupa Detroja on 04/02/19.
//  Copyright © 2017 Krupa Detroja. All rights reserved.

import UIKit

open class DropDownCell: UITableViewCell {
		
	//UI
	@IBOutlet open weak var optionLabel: UILabel!
    @IBOutlet open weak var imgIcon: UIImageView!
    var selectedBackgroundColor: UIColor?
}

// MARK: - UI
extension DropDownCell {
	
	override open func awakeFromNib() {
		super.awakeFromNib()
		backgroundColor = .clear
	}
	
	override open var isSelected: Bool {
		willSet {
			setSelected(newValue, animated: false)
		}
	}
	
	override open var isHighlighted: Bool {
		willSet {
			setSelected(newValue, animated: false)
		}
	}
	
	override open func setHighlighted(_ highlighted: Bool, animated: Bool) {
		setSelected(highlighted, animated: animated)
	}
	
	override open func setSelected(_ selected: Bool, animated: Bool) {
		let executeSelection: () -> Void = { [unowned self] in
			if let selectedBackgroundColor = self.selectedBackgroundColor {
                self.backgroundColor = selected ? selectedBackgroundColor : .clear
			}
		}
		if animated {
			UIView.animate(withDuration: 0.3, animations: {
				executeSelection()
			})
		} else {
			executeSelection()
		}
	}
}
