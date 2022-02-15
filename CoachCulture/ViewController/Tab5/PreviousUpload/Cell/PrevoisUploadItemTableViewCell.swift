//
//  PrevoisUploadItemTableViewCell.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 30/12/21.
//

import UIKit

class PrevoisUploadItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblClassDifficultyLevel : UILabel!
    @IBOutlet weak var lbltitle : UILabel!
    @IBOutlet weak var lblDuration : UILabel!
    @IBOutlet weak var lblFollowers : UILabel!
    @IBOutlet weak var lblClassDate : UILabel!
    @IBOutlet weak var lblClassType : UILabel!
    
    @IBOutlet weak var btnBookmark : UIButton!
   
    @IBOutlet weak var viwClassTypeContainer : UIView!
    
    @IBOutlet weak var imgClassCover : UIImageView!
    @IBOutlet weak var imgBookMark : UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
