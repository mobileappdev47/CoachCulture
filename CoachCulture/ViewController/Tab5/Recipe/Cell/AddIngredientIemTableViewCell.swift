//
//  AddIngredientIemTableViewCell.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 10/12/21.
//

import UIKit
import iOSDropDown


class AddIngredientIemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var txtQty : UITextField!
    @IBOutlet weak var txtIngredient : UITextField!
    @IBOutlet weak var lblUnit : UILabel!

    
    @IBOutlet weak var btnDelete : UIButton!
    @IBOutlet weak var btnSelectUnit : UIButton!
    var dropDown = DropDown()

    override func awakeFromNib() {
        super.awakeFromNib()
        dropDown.dataSource  = ["gm", "kg", "mg"]
        dropDown.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        dropDown.textColor = UIColor.white
        
        dropDown.anchorView = btnSelectUnit
        
    }
    
    func isNav() -> Bool {
        if txtQty.text == "" {
            Utility.shared.showToast("Enter Ingredients Quanitity")
            return false
        } else if txtIngredient.text == "" {
            Utility.shared.showToast("Enter qty unit type")
            return false
        } else if lblUnit.text == "" {
            Utility.shared.showToast("Enter Ingredients Name")
            return false
        } else {
            return true
        }
    }
    
    @IBAction func clickToBtnSelectUnit(_ sender : UIButton) {
        dropDown.show()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
