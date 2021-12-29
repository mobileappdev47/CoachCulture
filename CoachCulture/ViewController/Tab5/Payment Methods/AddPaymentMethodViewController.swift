//
//  AddPaymentMethodViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 23/12/21.
//

import UIKit
import FormTextField

class AddPaymentMethodViewController: BaseViewController {
    
    static func viewcontroller() -> AddPaymentMethodViewController {
        let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "AddPaymentMethodViewController") as! AddPaymentMethodViewController
        return vc
    }

    @IBOutlet weak var txtCardNumber : FormTextField!
    @IBOutlet weak var txtCardDate : FormTextField!
    @IBOutlet weak var txtCardHolderName : UITextField!
    @IBOutlet weak var txtCVV : FormTextField!
    
    @IBOutlet weak var viwCreditCard : UIView!
    @IBOutlet weak var viwDebitCard : UIView!
    
    @IBOutlet weak var btnCreditCard : UIView!
    @IBOutlet weak var btnDebitCard : UIView!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    // MARK: - Methods
    func setUpUI() {
        txtCardNumber.inputType = .integer
        txtCardNumber.formatter = CardNumberFormatter()
        txtCardNumber.textColor = UIColor.white
        var validation = Validation()
        validation.maximumLength = "1234 5678 1234 5678".count
        validation.minimumLength = "1234 5678 1234 5678".count
        let characterSet = NSMutableCharacterSet.decimalDigit()
        characterSet.addCharacters(in: " ")
        validation.characterSet = characterSet as CharacterSet
        let inputValidator = InputValidator(validation: validation)
        txtCardNumber.inputValidator = inputValidator
        txtCardNumber.clearButtonColor = .clear


        txtCardDate.formatter = CardExpirationDateFormatter()
        txtCardDate.inputType = .integer
        var validationDate = Validation()
        validationDate.minimumLength = 1
        let inputValidator1 = CardExpirationDateInputValidator(validation: validationDate)
        txtCardDate.inputValidator = inputValidator1
        txtCardNumber.textColor = UIColor.white
        
        
        txtCVV.inputType = .integer
        var validation1 = Validation()
        validation1.maximumLength = "CVC".count
        validation1.minimumLength = "CVC".count
        validation1.characterSet = CharacterSet.decimalDigits
        let inputValidator12 = InputValidator(validation: validation1)
        txtCVV.inputValidator = inputValidator12
        txtCardNumber.textColor = UIColor.white
        
    }
    
    //MARK: - CLICK EVENTS
    
    @IBAction func clickTobtnAddPaymentMethod( _ sender : UIButton) {
        if sender == btnCreditCard {
            viwCreditCard.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
            viwDebitCard.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        } else {
            viwCreditCard.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
            viwDebitCard.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
        }
    }
    
    @IBAction func clickTobtnAddSave( _ sender : UIButton) {
       
    }

}
