//
//  AddPaymentMethodViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 23/12/21.
//

import UIKit
import FormTextField
import Stripe

class AddPaymentMethodViewController: BaseViewController {
    
    static func viewcontroller() -> AddPaymentMethodViewController {
        let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "AddPaymentMethodViewController") as! AddPaymentMethodViewController
        return vc
    }
    @IBOutlet weak var imgAlertCVV: UIImageView!
    @IBOutlet weak var imgAlertCardDate: UIImageView!
    @IBOutlet weak var imgAlertCardName: UIImageView!
    @IBOutlet weak var imgAlertCardNumber: UIImageView!
    @IBOutlet weak var imgCard: UIImageView!
    @IBOutlet weak var txtCardNumber : FormTextField!
    @IBOutlet weak var txtCardDate : FormTextField!
    @IBOutlet weak var txtCardHolderName : UITextField!
    @IBOutlet weak var txtCVV : FormTextField!
    
    @IBOutlet weak var viwCreditCard : UIView!
    @IBOutlet weak var viwDebitCard : UIView!
    
    @IBOutlet weak var btnCreditCard : UIView!
    @IBOutlet weak var btnDebitCard : UIView!
    
    var selectedCardType = CardType.credit.rawValue
    var minimumLength = 0
    var maximumLength = 0
    var isCardValid = false
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    // MARK: - Methods
    func setUpUI() {
        txtCardHolderName.delegate = self
        
        txtCardNumber.inputType = .integer
        txtCardNumber.formatter = CardNumberFormatter()
        txtCardNumber.delegate = self
        txtCardNumber.defaultTextColor = .white
        var validation = Validation()
        validation.minimumLength = self.minimumLength
        validation.maximumLength = self.maximumLength
        let characterSet = NSMutableCharacterSet.decimalDigit()
        characterSet.addCharacters(in: " ")
        validation.characterSet = characterSet as CharacterSet
        let inputValidator = InputValidator(validation: validation)
        txtCardNumber.inputValidator = inputValidator
        txtCardNumber.clearButtonColor = .clear

        txtCardDate.formatter = CardExpirationDateFormatter()
        txtCardDate.delegate = self
        txtCardDate.inputType = .integer
        var validationDate = Validation()
        validationDate.minimumLength = 1
        validationDate.maximumLength = 4
        let inputValidator1 = CardExpirationDateInputValidator(validation: validationDate)
        txtCardDate.inputValidator = inputValidator1
        txtCardDate.defaultTextColor = .white
        
        txtCVV.inputType = .integer
        txtCVV.delegate = self
        var validation1 = Validation()
        validation1.maximumLength = 4
        validation1.minimumLength = "CVC".count
        validation1.characterSet = CharacterSet.decimalDigits
        let inputValidator12 = InputValidator(validation: validation1)
        txtCVV.inputValidator = inputValidator12
        txtCVV.defaultTextColor = .white
    }
    
    //MARK: - API CALL
    
    func callPaymentMethodsAPI() {
        showLoader()
        
        let dateComponents = txtCardDate.text?.components(separatedBy: "/")
        
        let apiUrl = STRIPE_API.payment_token
        var mainParams = [String:Any]()
                        
        mainParams["\(StripeParams.PaymentMethods.card)[\(StripeParams.Card.number)]"] = txtCardNumber.text?.replacingOccurrences(of: " ", with: "")
        mainParams["\(StripeParams.PaymentMethods.card)[\(StripeParams.Card.exp_month)]"] = dateComponents?.first ?? ""
        mainParams["\(StripeParams.PaymentMethods.card)[\(StripeParams.Card.exp_year)]"] = dateComponents?.last ?? ""
        mainParams["\(StripeParams.PaymentMethods.card)[\(StripeParams.Card.cvc)]"] = txtCVV.text ?? ""
//
        mainParams["\(StripeParams.PaymentMethods.card)[\(StripeParams.Card.name)]"] = txtCardHolderName.text ?? ""
        mainParams["\(StripeParams.PaymentMethods.card)[\(StripeParams.PaymentMethods.metadata)][\(StripeParams.Metadata.card_number)]"] = txtCardNumber.text?.replacingOccurrences(of: " ", with: "")
//        mainParams["\(StripeParams.PaymentMethods.metadata)[\(StripeParams.Metadata.card_type)]"] = selectedCardType
//
//        mainParams["\(StripeParams.PaymentMethods.billing_details)[\(StripeParams.BillingDetails.address)][\(StripeParams.BillingDetails.Address.city)]"] = "Miami"
//        mainParams["\(StripeParams.PaymentMethods.billing_details)[\(StripeParams.BillingDetails.address)][\(StripeParams.BillingDetails.Address.country)]"] = "US"
//        mainParams["\(StripeParams.PaymentMethods.billing_details)[\(StripeParams.BillingDetails.address)][\(StripeParams.BillingDetails.Address.line1)]"] = "street, PO Box"
//        mainParams["\(StripeParams.PaymentMethods.billing_details)[\(StripeParams.BillingDetails.address)][\(StripeParams.BillingDetails.Address.line2)]"] = "apartment, suite, unit, or building"
//        mainParams["\(StripeParams.PaymentMethods.billing_details)[\(StripeParams.BillingDetails.address)][\(StripeParams.BillingDetails.Address.postal_code)]"] = "33142"
//        mainParams["\(StripeParams.PaymentMethods.billing_details)[\(StripeParams.BillingDetails.address)][\(StripeParams.BillingDetails.Address.state)]"] = "florida"
//
//        mainParams["\(StripeParams.PaymentMethods.billing_details)[\(StripeParams.BillingDetails.email)]"] = "harsh.web.stackapp@gmail.com"
//        mainParams["\(StripeParams.PaymentMethods.billing_details)[\(StripeParams.BillingDetails.name)]"] = "Derious"
//        mainParams["\(StripeParams.PaymentMethods.billing_details)[\(StripeParams.BillingDetails.phone)]"] = "+91 7410410123"
        
//        mainParams[StripeParams.PaymentMethods.type] = "card"
        
        _ =  ApiCallManager.requestApiStripe(method: .post, urlString: apiUrl, parameters: mainParams, headers: nil) { responseObj, statusCode in
            if statusCode == RESPONSE_CODE.SUCCESS {
                if let id = responseObj["id"] as? String {
                    if Reachability.isConnectedToNetwork() {
                        self.callPaymentMethodsAttachAPI(customerID: id)
                    }
                }
            } else {
                self.hideLoader()
                if let error = responseObj["error"] as? [String:Any] {
                    if let message = error["message"] as? String {
                        Utility.shared.showToast(message)
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
        let apiUrl = "\(STRIPE_API.payment_add_card)/\(AppPrefsManager.sharedInstance.getUserData().stripe_customer_id)/sources"
        var mainParams = [String:Any]()
        
        mainParams["\(StripeParams.PaymentMethodsAttach.source)"] = customerID
        
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
    
    func checkValidation() -> Bool {
        if txtCardNumber.text?.isEmpty ?? false {
            Utility.shared.showToast("Card number is mandatory field")
            return false
        } else if !isCardValid {
            Utility.shared.showToast("Card number is invalid")
            return false
        } else if txtCardHolderName.text?.isEmpty ?? false {
            Utility.shared.showToast("Card holder name is mandatory field")
            imgAlertCardName.isHidden = false
            return false
        } else if txtCardDate.text?.isEmpty ?? false {
            Utility.shared.showToast("Expiration date is mandatory field")
            imgAlertCardDate.isHidden = false
            return false
        } else if txtCVV.text?.isEmpty ?? false {
            Utility.shared.showToast("CVV is mandatory field")
            imgAlertCVV.isHidden = false
            return false
        } else {
            imgAlertCVV.isHidden = true
            imgAlertCardDate.isHidden = true
            imgAlertCardName.isHidden = true
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
        if checkValidation() {
            if Reachability.isConnectedToNetwork() {
                callPaymentMethodsAPI()
            }
        }
    }
}

enum CardType: String {
    case credit = "credit"
    case debit = "debit"
}

extension AddPaymentMethodViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let fullStr = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField == txtCardNumber {
            self.minimumLength = 12
            if fullStr.count == 0 {
                self.maximumLength = 0
            }
            let cardBrand = STPCardValidator.brand(forNumber: fullStr)
            let cardImage = STPImageLibrary.cardBrandImage(for: cardBrand)
            imgCard.image = cardImage
            
            self.maximumLength = getMaxLength(cardBrand: cardBrand)
            
            if CreditCardValidator(fullStr).isValid(for: .amex) || CreditCardValidator(fullStr).isValid(for: .dinersClub) || CreditCardValidator(fullStr).isValid(for: .discover) || CreditCardValidator(fullStr).isValid(for: .elo) || CreditCardValidator(fullStr).isValid(for: .hipercard) || CreditCardValidator(fullStr).isValid(for: .jcb) || CreditCardValidator(fullStr).isValid(for: .maestro) || CreditCardValidator(fullStr).isValid(for: .masterCard) || CreditCardValidator(fullStr).isValid(for: .mir) || CreditCardValidator(fullStr).isValid(for: .unionPay) || CreditCardValidator(fullStr).isValid(for: .visa) || CreditCardValidator(fullStr).isValid(for: .visaElectron) {
                imgAlertCardNumber.isHidden = false
                imgAlertCardNumber.image = UIImage(named: "successRight")
                isCardValid = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.txtCardNumber.resignFirstResponder()
                }
            } else {
                if fullStr.replacingOccurrences(of: " ", with: "").count == self.maximumLength {
                    isCardValid = false
                    imgAlertCardNumber.image = UIImage(named: "ic_wrong")
                    imgAlertCardNumber.isHidden = false
                }
            }
            return fullStr.replacingOccurrences(of: " ", with: "").count <= self.maximumLength
        } else if textField == txtCardHolderName {
            if fullStr.isEmpty {
                imgAlertCardName.isHidden = false
            } else {
                imgAlertCardName.isHidden = true
            }
            return true
        } else if textField == txtCardDate {
            if fullStr.isEmpty {
                imgAlertCardDate.isHidden = false
            } else {
                imgAlertCardDate.isHidden = true
            }
            return fullStr.count <= 7
        } else if textField == txtCVV {
            if fullStr.isEmpty {
                imgAlertCVV.isHidden = false
            } else {
                imgAlertCVV.isHidden = true
            }
            return fullStr.count <= 4
        }
        imgAlertCVV.isHidden = true
        imgAlertCardDate.isHidden = true
        imgAlertCardName.isHidden = true
        return true
    }
}

enum CardBrand: String {
    /// Visa card
    case visa
    /// American Express card
    case amex
    /// Mastercard card
    case mastercard
    /// Discover card
    case discover
    /// JCB card
    case JCB
    /// Diners Club card
    case dinersClub
    /// UnionPay card
    case unionPay
    /// An unknown card brand type
    case maestro
    case mir
    case hipercard
    case unknown
}

func getMaxLength(cardBrand: STPCardBrand) -> Int {
    switch cardBrand {
    case .visa:
        return 16
    case .amex:
        return 15
    case .maestro:
        return 19
    case .dinersClub:
        return 19
    case .JCB, .discover, .unionPay, .mir:
        return 19
    case .hipercard:
        return 16
    default:
        return 16
    }
}
