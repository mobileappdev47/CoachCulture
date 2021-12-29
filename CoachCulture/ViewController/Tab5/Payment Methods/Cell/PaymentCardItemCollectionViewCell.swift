//
//  PaymentCardItemCollectionViewCell.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 22/12/21.
//

import UIKit

class PaymentCardItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgCardType : UIImageView!
    @IBOutlet weak var lblCardNo : UILabel!
    @IBOutlet weak var lblCardHolderName : UILabel!
    @IBOutlet weak var lblCvv : UILabel!
    @IBOutlet weak var lblValidThrough : UILabel!
    
    @IBOutlet weak var viwMainContainer : UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
