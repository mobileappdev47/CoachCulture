//
//  UserReviewItemTableViewCell.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 21/12/21.
//

import UIKit
import HCSStarRatingView

class UserReviewItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var viwRating: HCSStarRatingView!
    @IBOutlet weak var lbluserName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblReviewDes: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
