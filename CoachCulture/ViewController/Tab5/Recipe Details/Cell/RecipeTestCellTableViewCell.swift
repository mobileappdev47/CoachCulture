//
//  RecipeTestCellTableViewCell.swift
//  CoachCulture
//
//  Created by Brainbinary Infotech on 25/02/22.
//

import UIKit

class RecipeTestCellTableViewCell: UITableViewCell {

    @IBOutlet weak var lblIndex: UILabel!
    @IBOutlet weak var lblRecipeData: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
