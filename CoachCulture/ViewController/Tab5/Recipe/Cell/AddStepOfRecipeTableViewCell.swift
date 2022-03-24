//
//  AddStepOfRecipeTableViewCell.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 10/12/21.
//

import UIKit
import KMPlaceholderTextView

class AddStepOfRecipeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var txtAddStepRecipe: KMPlaceholderTextView!
    
    @IBOutlet weak var lblCharCount: UILabel!
    @IBOutlet weak var btnDelete: UIButton!

    @IBOutlet weak var txtDummyStap: UITextField!
    @IBOutlet weak var imgErrStaps: UIImageView!
    
    static var isHidden = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if isHidden {
            txtDummyStap.setError("Please enter recipe's step details", show: true)
            imgErrStaps.isHidden = false
        } else {
            txtDummyStap.setError()
            imgErrStaps.isHidden = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
