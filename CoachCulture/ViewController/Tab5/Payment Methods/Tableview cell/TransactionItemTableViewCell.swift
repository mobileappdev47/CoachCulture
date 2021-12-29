//
//  TransactionItemTableViewCell.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 23/12/21.
//

import UIKit

class TransactionItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var imgSubscription: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
