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
    var dropDown2 = DropDown()
    var ddArr = [ "Chopped Raw Vegetables",
                  "Nuts and Seeds",
                  "Dried Fruit",
                  "Baked Tortilla or Pita Chips",
                  "Fresh Fruit",
                  "Beans and Legumes",
                  "Whole Grains"]
    var ddDelegete = AddIngredientsForRecipeViewController()

    override func awakeFromNib() {
        super.awakeFromNib()
        dropDown.dataSource  = ["gm", "kg", "mg"]
        dropDown2.dataSource  = ddArr
        
        dropDown.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        dropDown.textColor = UIColor.white
        
        dropDown2.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        dropDown2.textColor = UIColor.white
        
        dropDown.anchorView = btnSelectUnit
        dropDown2.anchorView = txtIngredient
        
        dropDown.cellHeight = 50
        dropDown2.cellHeight = 50
        
        txtIngredient.delegate = self
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

//MARK: - UITextFieldDelegate
extension AddIngredientIemTableViewCell : UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        dropDown2.show()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
}
