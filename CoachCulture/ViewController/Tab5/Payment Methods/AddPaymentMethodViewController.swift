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
    
    var selectedCardType = CardType.credit.rawValue
    
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
    
    //MARK: - API CALL
    
    func callPaymentMethodsAPI() {
        showLoader()
        
        let dateComponents = txtCardDate.text?.components(separatedBy: "/")
        
        let apiUrl = STRIPE_API.payment_methods
        var mainParams = [String:Any]()
                        
        mainParams["\(StripeParams.PaymentMethods.card)[\(StripeParams.Card.number)]"] = txtCardNumber.text?.replacingOccurrences(of: " ", with: "")
        mainParams["\(StripeParams.PaymentMethods.card)[\(StripeParams.Card.exp_month)]"] = dateComponents?.first ?? ""
        mainParams["\(StripeParams.PaymentMethods.card)[\(StripeParams.Card.exp_year)]"] = dateComponents?.last ?? ""
        mainParams["\(StripeParams.PaymentMethods.card)[\(StripeParams.Card.cvc)]"] = txtCVV.text ?? ""

        mainParams["\(StripeParams.PaymentMethods.metadata)[\(StripeParams.Metadata.holder_name)]"] = txtCardHolderName.text ?? ""
        mainParams["\(StripeParams.PaymentMethods.metadata)[\(StripeParams.Metadata.card_number)]"] = txtCardNumber.text?.replacingOccurrences(of: " ", with: "")
        mainParams["\(StripeParams.PaymentMethods.metadata)[\(StripeParams.Metadata.card_type)]"] = selectedCardType
        
        mainParams["\(StripeParams.PaymentMethods.billing_details)[\(StripeParams.BillingDetails.address)][\(StripeParams.BillingDetails.Address.city)]"] = "Miami"
        mainParams["\(StripeParams.PaymentMethods.billing_details)[\(StripeParams.BillingDetails.address)][\(StripeParams.BillingDetails.Address.country)]"] = "US"
        mainParams["\(StripeParams.PaymentMethods.billing_details)[\(StripeParams.BillingDetails.address)][\(StripeParams.BillingDetails.Address.line1)]"] = "street, PO Box"
        mainParams["\(StripeParams.PaymentMethods.billing_details)[\(StripeParams.BillingDetails.address)][\(StripeParams.BillingDetails.Address.line2)]"] = "apartment, suite, unit, or building"
        mainParams["\(StripeParams.PaymentMethods.billing_details)[\(StripeParams.BillingDetails.address)][\(StripeParams.BillingDetails.Address.postal_code)]"] = "33142"
        mainParams["\(StripeParams.PaymentMethods.billing_details)[\(StripeParams.BillingDetails.address)][\(StripeParams.BillingDetails.Address.state)]"] = "florida"
        
        mainParams["\(StripeParams.PaymentMethods.billing_details)[\(StripeParams.BillingDetails.email)]"] = "harsh.web.stackapp@gmail.com"
        mainParams["\(StripeParams.PaymentMethods.billing_details)[\(StripeParams.BillingDetails.name)]"] = "Derious"
        mainParams["\(StripeParams.PaymentMethods.billing_details)[\(StripeParams.BillingDetails.phone)]"] = "+91 7410410123"
        
        mainParams[StripeParams.PaymentMethods.type] = "card"
        
        _ =  ApiCallManager.requestApiStripe(method: .post, urlString: apiUrl, parameters: mainParams, headers: nil) { responseObj, statusCode in
            if statusCode == RESPONSE_CODE.SUCCESS {
                if let id = responseObj["id"] as? String {
                    if Reachability.isConnectedToNetwork() {
                        self.callPaymentMethodsAttachAPI(customerID: id)
                    }
                }
            }
        } failure: { (error) in
            self.hideLoader()
            Utility.shared.showToast(error.localizedDescription)
            return true
        }
    }
    
    func callPaymentMethodsAttachAPI(customerID: String) {
        let apiUrl = "\(STRIPE_API.payment_methods)/\(customerID)/attach"
        var mainParams = [String:Any]()
        
        mainParams["\(StripeParams.PaymentMethodsAttach.customer)"] = AppPrefsManager.sharedInstance.getUserData().stripe_customer_id
        
        _ =  ApiCallManager.requestApiStripe(method: .post, urlString: apiUrl, parameters: mainParams, headers: nil) { responseObj, statusCode in
            self.hideLoader()
            if statusCode == RESPONSE_CODE.SUCCESS {
                self.popVC(animated: true)
            }
        } failure: { (error) in
            self.hideLoader()
            Utility.shared.showToast(error.localizedDescription)
            return true
        }
    }
    
    //MARK: - CLICK EVENTS
    
    @IBAction func clickTobtnAddPaymentMethod( _ sender : UIButton) {
        if sender == btnCreditCard {
            selectedCardType = CardType.credit.rawValue
            viwCreditCard.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
            viwDebitCard.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        } else {
            selectedCardType = CardType.debit.rawValue
            viwCreditCard.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
            viwDebitCard.backgroundColor = hexStringToUIColor(hex: "#ACBACA")
        }
    }
    
    @IBAction func clickTobtnAddSave( _ sender : UIButton) {
        if Reachability.isConnectedToNetwork() {
            callPaymentMethodsAPI()
        }
    }
}

enum CardType: String {
    case credit = "credit"
    case debit = "debit"
}
