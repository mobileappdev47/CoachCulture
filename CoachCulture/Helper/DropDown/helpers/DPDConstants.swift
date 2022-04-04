//
//  Constants.swift
//  DropDown
//
// GoLeagueMembers
//  Created by Krupa Detroja on 04/02/19.
//  Copyright © 2017 Krupa Detroja. All rights reserved.

import UIKit

internal struct DPDConstant {

	internal struct KeyPath {

		static let Frame = "frame"

	}

	internal struct ReusableIdentifier {

		static let DropDownCell = "DropDownCell"

	}

	internal struct UI {
        static let TextColor = UIColor.darkGray
		static let TextFont = UIFont(name: "SFProText-Bold", size: 14)
		static let BackgroundColor = UIColor.white
		static let SelectionBackgroundColor = UIColor(white: 0.89, alpha: 1)
		static let SeparatorColor = UIColor.clear
		static let CornerRadius: CGFloat = 10
		static let RowHeight: CGFloat = 56
		static let HeightPadding: CGFloat = 20

		struct Shadow {

			static let Color = UIColor.darkGray
			static let Offset = CGSize.zero
			static let Opacity: Float = 0.4
			static let Radius: CGFloat = 8
		}
	}

	internal struct Animation {

		static let Duration = 0.15
        static let EntranceOptions: UIView.AnimationOptions = [.allowUserInteraction, .curveEaseOut]
        static let ExitOptions: UIView.AnimationOptions = [.allowUserInteraction, .curveEaseIn]
		static let DownScaleTransform = CGAffineTransform(scaleX: 0.9,y: 0.9)

	}

}
