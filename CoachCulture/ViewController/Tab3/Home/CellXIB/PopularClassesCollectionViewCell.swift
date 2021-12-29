//
//  PopularClassesCollectionViewCell.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 02/12/21.
//

import UIKit

class PopularClassesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgUser : UIImageView!

    @IBOutlet weak var viwTopStatusContainer : UIView!
    
    @IBOutlet weak var lblStatus : UILabel!
    @IBOutlet weak var lblTime : UILabel!
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var lblViews : UILabel!
    @IBOutlet weak var lblClassSubTitle : UILabel!
    @IBOutlet weak var lblClassType : UILabel!


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setData(obj: PopularClassList) {
        lblStatus.text = obj.coach_class_type
        lblTime.text = obj.duration
        lblName.text = "@" + obj.username
        lblViews.text = obj.total_viewers + " Followers"
        lblClassSubTitle.text = obj.class_subtitle
        lblClassType.text = obj.class_type
        if obj.coach_class_type == CoachClassType.live {
            viwTopStatusContainer.backgroundColor = hexStringToUIColor(hex: "#CC2936")
        }
        
        if obj.coach_class_type == CoachClassType.onDemand {
            viwTopStatusContainer.backgroundColor = hexStringToUIColor(hex: "#1A82F6")
        }
        imgUser.setImageFromURL(imgUrl: obj.thumbnail_url, placeholderImage: nil)
    }

}
