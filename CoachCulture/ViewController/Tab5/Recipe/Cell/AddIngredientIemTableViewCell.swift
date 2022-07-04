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
//    var ddDelegete = AddIngredientsForRecipeViewController()
    var arrIngredient = [String]()
    var didTapBack : (() -> Void)!
    var didChangeQTYValue: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dropDown.dataSource  = ["g", "ml", "tbsp", "tsp", "cup", "liter", "fl oz", "gallon", "pint"]
//        let continentObj = Utility.shared.readLocalFile(forName: "name_to_id_mapping")
//        _ = continentObj?.filter({ (dict) -> Bool in
//            arrIngredient.append(dict.key)
//            return dict.key == ""
//        })
        
        dropDown2.dataSource = arrIngredient
        
        dropDown.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        dropDown.textColor = UIColor.white
        
        dropDown2.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        dropDown2.textColor = UIColor.white
        
        dropDown.anchorView = btnSelectUnit
        dropDown2.anchorView = txtIngredient
        dropDown2.bottomOffset = CGPoint(x: 16, y: txtIngredient.bounds.height)
        
        dropDown.cellHeight = 50
        dropDown2.cellHeight = 50
        
//        txtIngredient.delegate = self
        txtIngredient.addTarget(self, action: #selector(filterText(_:)), for: .editingChanged)
        txtQty.addTarget(self, action: #selector(didChangeQty(_:)), for: .editingChanged)
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
    
    @objc func filterText(_ txt: UITextField) {
        var array = [""]
        array = self.arrIngredient.filter({$0.lowercased().contains(txt.text!.lowercased())})
        self.dropDown2.dataSource = array
        if array.count > 0 && dropDown2.isHidden {
            DispatchQueue.main.async {
                self.dropDown2.show()
            }
        } else {
            dropDown2.reloadAllComponents()
        }
    }
    
    @objc private func didChangeQty(_ txt: UITextField) {
        didChangeQTYValue?(txt.text!)
    }
    
    @IBAction func clickToBtnSelectUnit(_ sender : UIButton) {
        dropDown.show()
    }
    
}

//MARK: - UITextFieldDelegate
//extension AddIngredientIemTableViewCell : UITextFieldDelegate {
//
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
////        let finalString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
//        filterText("")
//        return true
//    }
//
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        return true
//    }
//
//}
