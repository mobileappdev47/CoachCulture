//
//  PopularTrainerCollectionViewCell.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 02/12/21.
//

import UIKit

class PopularTrainerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblName : UILabel!
    @IBOutlet weak var lblFollower : UILabel!
    @IBOutlet weak var imgUser : UIImageView!
    @IBOutlet weak var imgThumbnail : UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setData(obj:PopularTrainerList) {
        lblName.text = "@" + obj.username
        imgUser.setImageFromURL(imgUrl: obj.user_image, placeholderImage: nil)
        lblFollower.text = obj.total_followers + " Followers"
        imgThumbnail.setImageFromURL(imgUrl: obj.user_image, placeholderImage: nil)
        imgThumbnail.blurImage()
    }

}
