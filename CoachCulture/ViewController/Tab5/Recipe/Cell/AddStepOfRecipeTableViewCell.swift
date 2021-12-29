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


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
