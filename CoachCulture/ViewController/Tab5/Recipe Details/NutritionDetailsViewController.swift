//
//  NutritionDetailsViewController.swift
//  CoachCulture
//
//  Created by Mayur on 29/06/22.
//

import UIKit

class NutritionDetailsViewController: UIViewController {
    
    @IBOutlet weak var lblCaloriesValue: UILabel!
    @IBOutlet weak var lblTotalFatKey: UILabel!
    @IBOutlet weak var lblTotalFatValue: UILabel!
    @IBOutlet weak var lblSaturatedFatKey: PaddingLabel!
    @IBOutlet weak var lblSaturatedFatValue: UILabel!
    @IBOutlet weak var lblCholesterolKey: UILabel!
    @IBOutlet weak var lblCholesterolValue: UILabel!
    @IBOutlet weak var lblSodiumKey: UILabel!
    @IBOutlet weak var lblSodiumValue: UILabel!
    @IBOutlet weak var lblCarbohydredKey: UILabel!
    @IBOutlet weak var lblCarbohydredValue: UILabel!
    @IBOutlet weak var lblProteinKey: UILabel!
    @IBOutlet weak var lblProteinValue: UILabel!
    @IBOutlet weak var lblVitaminKey: UILabel!
    @IBOutlet weak var lblVitaminValue: UILabel!
    @IBOutlet weak var lblCalciumKey: UILabel!
    @IBOutlet weak var lblCalciumValue: UILabel!
    @IBOutlet weak var lblIronKey: UILabel!
    @IBOutlet weak var lblIronValue: UILabel!
    @IBOutlet weak var lblPotessiumKey: UILabel!
    @IBOutlet weak var lblPotessiumValue: UILabel!
    @IBOutlet weak var lblFiberKey: PaddingLabel!
    @IBOutlet weak var lblFiberValue: UILabel!
    @IBOutlet weak var lblSugarsKey: PaddingLabel!
    @IBOutlet weak var lblSugarsValue: UILabel!
    @IBOutlet weak var lblNutritionDietDesc: UILabel!
    
    @IBOutlet weak var btnClose: UIButton! {
        didSet {
            btnClose.addTarget(self, action: #selector(didTapClose(_:)), for: .touchUpInside)
        }
    }
    
    var nutritionData = [DataKeyValue]()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard nutritionData.count > 0 else {return}
        setData()
    }
    
    private func setData() {
        let textKeys = [lblTotalFatKey,
                        lblSaturatedFatKey,
                        lblCholesterolKey,
                        lblSodiumKey,
                        lblCarbohydredKey,
                        lblFiberKey,
                        lblSugarsKey,
                        lblProteinKey,
                        lblVitaminKey,
                        lblCalciumKey,
                        lblIronKey,
                        lblPotessiumKey]
        
        let textValues = [
                        lblTotalFatValue,
                        lblSaturatedFatValue,
                        lblCholesterolValue,
                          lblSodiumValue,
                        lblCarbohydredValue,
                        lblFiberValue,
                        lblSugarsValue,
                        lblProteinValue,
                        lblVitaminValue,
                        lblCalciumValue,
                        lblIronValue,
                        lblPotessiumValue]
        
        let textAttributes = ["Total Fat",
                              "Saturated Fat",
                              "Cholesterol",
                              "Sodium",
                              "Total Carbohydrate",
                              "Dietary Fiber",
                              "Total Sugars",
                              "Protein",
                              "Vitamin D",
                              "Calcium",
                              "Iron",
                              "Potassium"]
        
        
        for i in 1..<nutritionData.count {
            let index = i - 1
            let keyData = textAttributes[index] + " " + nutritionData[i].key
            if index == 0 || index == 2 || index == 3 || index == 4 || index == 7 {
                textKeys[index]!.attributedText = keyData.withBoldText(text: textAttributes[index], font: UIFont.systemFont(ofSize: 15))
            } else {
                textKeys[index]!.attributedText = keyData.withBoldText(text: "", font: UIFont.systemFont(ofSize: 15))
            }
            textValues[index]!.text = nutritionData[i].value
        }
        let calValue = nutritionData[0].key
        lblCaloriesValue.text = calValue
        let desc = "*The % Dailv Value (DV) tells vou how much a nutrient in a food serving contribution to a daily diet. \(calValue) calorie a day is used for general nutrition advice."
        let attrb = NSMutableAttributedString(string: desc, attributes: [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        if let substringRange = desc.range(of: "\(calValue) calorie a day") {
            let nsRange = NSRange(substringRange, in: desc)
            attrb.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.blue, NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: nsRange)
            lblNutritionDietDesc.attributedText = attrb
        }
        
        paddingLbls(lbl: lblSaturatedFatKey)
        paddingLbls(lbl: lblFiberKey)
        paddingLbls(lbl: lblSugarsKey)
    }
    
    func paddingLbls(lbl: PaddingLabel) {
        lbl.paddingLeft = 10
        lbl.paddingRight = 0
        lbl.paddingTop = 0
        lbl.paddingBottom = 0
    }

    @objc private func didTapClose(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
