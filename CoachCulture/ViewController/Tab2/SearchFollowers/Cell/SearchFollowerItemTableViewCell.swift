//
//  SearchFollowerItemTableViewCell.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 20/12/21.
//

import UIKit

class SearchFollowerItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgUser: UIImageView!
    
    @IBOutlet weak var lblFollowers: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgUser.addCornerRadius(5)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
