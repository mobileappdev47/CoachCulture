//
//  CoachViseOnDemandClassItemTableViewCell.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 20/12/21.
//

import UIKit

class CoachViseOnDemandClassItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblClassDifficultyLevel : UILabel!
    @IBOutlet weak var lbltitle : UILabel!
    @IBOutlet weak var lblClassDate : UILabel!
    @IBOutlet weak var lblClassTime : UILabel!
    @IBOutlet weak var lblDuration : UILabel!
    @IBOutlet weak var lblClassType : UILabel!
   
    @IBOutlet weak var imgProfileBottom: UIImageView!
    @IBOutlet weak var viewProfileBottom: UIView!
    @IBOutlet weak var viewProfile: UIView!
    @IBOutlet weak var imgProfileBanner: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    
    @IBOutlet weak var viwClassTypeContainer : UIView!
    @IBOutlet weak var imgUser : UIImageView!
    @IBOutlet weak var imgBookMark : UIImageView!
    @IBOutlet weak var btnBookMark : UIButton!
    @IBOutlet weak var btnUser: UIButton!
    
    //MARK: - VARIABLE AND OBJECT
    
    var didTapBookmarkButton : (() -> Void)!
    var selectedIndex = 0
    
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
}
