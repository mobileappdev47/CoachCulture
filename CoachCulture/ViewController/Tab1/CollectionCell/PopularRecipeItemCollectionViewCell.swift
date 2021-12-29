//
//  PopularRecipeItemCollectionViewCell.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 20/12/21.
//

import UIKit

class PopularRecipeItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblDuration : UILabel!
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblSubtitle : UILabel!
    @IBOutlet weak var lblUserName : UILabel!
    @IBOutlet weak var lblViews : UILabel!
    
    @IBOutlet weak var imgRecipe : UIImageView!
    @IBOutlet weak var imgThumbnail : UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
