//
//  AddEquipmentItemTableViewCell.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 07/12/21.
//

import UIKit

class AddEquipmentItemTableViewCell: UITableViewCell {

    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var btnDelete : UIButton!
    @IBOutlet weak var btnSelectItem : UIButton!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
