//
//  RecipeIngredientTableViewCell.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 11/12/21.
//

import UIKit

class RecipeIngredientTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblQty : UILabel!
    @IBOutlet weak var lblIngredient : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
