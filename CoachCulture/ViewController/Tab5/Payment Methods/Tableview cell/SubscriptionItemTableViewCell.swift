//
//  SubscriptionItemTableViewCell.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 23/12/21.
//

import UIKit

class SubscriptionItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgUser: UIImageView!
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblSubscriptionPrice: UILabel!
    @IBOutlet weak var viwUnsubscribe: UIView!
    @IBOutlet weak var viwSubscribe: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    
    var didTapUnsubscribeClick : (() -> Void)!
    var selectedIndex = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viwSubscribe.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnUnsubscribeClick() {
        if didTapUnsubscribeClick != nil {
            didTapUnsubscribeClick()
        }
    }
}
