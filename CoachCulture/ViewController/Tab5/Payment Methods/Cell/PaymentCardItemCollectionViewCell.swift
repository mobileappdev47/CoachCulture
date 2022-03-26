//
//  PaymentCardItemCollectionViewCell.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 22/12/21.
//

import UIKit

class PaymentCardItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnSelectPreffered: UIButton!
    @IBOutlet weak var viewPrefferedMethodMainBG: UIView!
    @IBOutlet weak var imgCardType : UIImageView!
    @IBOutlet weak var lblCardNo : UILabel!
    @IBOutlet weak var lblCardHolderName : UILabel!
    @IBOutlet weak var lblCvv : UILabel!
    @IBOutlet weak var lblValidThrough : UILabel!
    @IBOutlet weak var viewDeleteConfirmationMain: UIView!
    @IBOutlet weak var viewMainBG: UIView!
    
    var isFromCellSelection = false
    var cellIndex = 0
    var bgColor = UIColor()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
