//
//  SearchResultItemTableViewCell.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 20/12/21.
//

import UIKit
import HCSStarRatingView

class SearchResultItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var viewBlur: UIView!
    @IBOutlet weak var lblClassDifficultyLevel : UILabel!
    @IBOutlet weak var lbltitle : UILabel!
    @IBOutlet weak var lblDuration : UILabel!
    @IBOutlet weak var lblUserName : UILabel!
    @IBOutlet weak var lblClassDate : UILabel!
    @IBOutlet weak var lblClassTime : UILabel!
    @IBOutlet weak var lblClassType : UILabel!
    
    @IBOutlet weak var viwRating : HCSStarRatingView!
    @IBOutlet weak var viwRatingContainer : UIView!
    @IBOutlet weak var btnRating : UIButton!
    @IBOutlet weak var btnBookmark : UIButton!
   
    @IBOutlet weak var viwClassTypeContainer : UIView!
    
    @IBOutlet weak var imgUser : UIImageView!
    @IBOutlet weak var imgClassCover : UIImageView!
    @IBOutlet weak var imgBookMark : UIImageView!
    @IBOutlet weak var imgThumbnail : UIImageView!
    @IBOutlet weak var viewProfile: UIView!
    @IBOutlet weak var btnUser: UIButton!
    
    var didTapBookmarkButton : (() -> Void)!
    var selectedIndex = 0
    var recipeDetailDataObj = RecipeDetailData()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: - ACTION
    
    @IBAction func btnBookmarkClick(_ sender: Any) {
        if didTapBookmarkButton != nil {
            didTapBookmarkButton()
        }
    }
    @IBAction func btnRatingTap(_ sender: UIButton) {        
    }
}
