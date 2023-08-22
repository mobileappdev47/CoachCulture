//
//  OTPViewController.swift
//  CoachCulture
//
//  Created by Mayur Boghani on 29/10/21.
//

import UIKit
import SVProgressHUD
import DPOTPView

class OTPViewController: BaseViewController {
    
    static func viewcontroller() -> OTPViewController {
        let vc = UIStoryboard(name: "Coach", bundle: nil).instantiateViewController(withIdentifier: "OTPViewController") as! OTPViewController
        return vc
    }
    
    
    @IBOutlet weak var phonenoLable: UILabel!
    @IBOutlet weak var phoneCodeLable: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnResend: UIButton!
    @IBOutlet weak var btnChangeNumber: UIButton!
    @IBOutlet weak var lblCounter: UILabel!
    
    @IBOutlet var otpView: DPOTPView!
    @IBOutlet var btnDigits: [UIButton]!
    @IBOutlet var txtOtps: [UILabel]!
    
    
    var countryCode = ""
    var phoneCode = ""
    var phoneNo = ""
    var username = ""
    var password = ""
    var otp = ""
    var verifiedCallback: (() -> Void)?
    //    var verifyotp = "1234"
    let apimanager = ApiManager()
    var counter = 60
    var timer = Timer()
    var isFromForgotPassword = false
    var emaiOrPhone = ""
    var phoneX = ""
    var LoginType = LoginTypeConst(rawValue: 0)
    var paramDic = [String:Any]()
    var isFromInitial = false
    var email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        otpView.dpOTPViewDelegate = self
        isFromInitial = true
        tapResendTimer()
        btnResend.addTarget(self, action: #selector(didTapResend(_:)), for: .touchUpInside)
        btnChangeNumber.addTarget(self, action: #selector(didTapChangeNumber(_:)), for: .touchUpInside)
        /*btnDigits.forEach { btn in
         btn.addTarget(self, action: #selector(didTapDigit(_:)), for: .touchUpInside)
         }*/
//        phoneCodeLable.text = phoneCode
//        phonenoLable.text = phoneNo
        btnResend.setTitle("Resent OTP", for: .normal)
        btnChangeNumber.setTitle("Change Number", for: .normal)
        btnResend.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btnChangeNumber.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        
                
        if !emaiOrPhone.isEmpty {
            let seperatedComponents = emaiOrPhone.components(separatedBy: "@")
            var formattedFirstPart = ""
                        
            for (index, recdChar) in seperatedComponents.first!.enumerated() {
                if index != 0 {
                    formattedFirstPart.append("*")
                } else {
                    formattedFirstPart.append(recdChar)
                }
            }
            let finalPart = "\(formattedFirstPart)@\(seperatedComponents.last ?? "")"
            lblDesc.text = "Please type the verification code sent to \(finalPart)"
        } else {
            let count = phoneNo.count
            phoneX.removeAll()
            for _ in 0..<count {
                phoneX.append("x")
            }

            lblDesc.text = "Please type the verification code sent to \(phoneCode) \(phoneX)."
        }
    }
    
    fileprivate func tapResendTimer() {
        update()
        counter = 60
        lblCounter.isHidden = false
        self.btnResend.isEnabled = false
        lblCounter.text = "in 00:60"
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        if(counter > 0) {
            let minutes = String(counter / 60)
            let seconds = String(counter % 60)
            if Int(seconds)! < 10 {
                if !isFromInitial {
                    lblCounter.text = "in 0\(minutes)" + ":" + "0\(seconds)"
                } else {
                    lblCounter.text = "in 00:60"
                }
            } else {
                lblCounter.text = "in 0\(minutes)" + ":" + seconds
                isFromInitial = false
            }
            counter -= 1
        } else {
            isFromInitial = true
            self.timer.invalidate()
            self.lblCounter.isHidden = true
            self.btnResend.isEnabled = true
        }
    }
    
    @objc func didTapChangeNumber(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapResend(_ sender: UIButton) {
        self.resendOtpAPI()
    }
}

//MARK: - EXTENSION API CALL
extension OTPViewController {
    
    func verifyAPI() {
        view.endEditing(true)
        var param = [String:Any]()
        
        if LoginType == LoginTypeConst.Google {
            param["signup_type"] = LoginTypeConst.Google.rawValue
        } else if LoginType == LoginTypeConst.Facebook {
            param["signup_type"] = LoginTypeConst.Facebook.rawValue
        } else {
            param["signup_type"] = LoginTypeConst.Standard.rawValue
            param["password"] = password
        }
        
        param["username"] = username
        param["countrycode"] = countryCode
        param["phonecode"] = phoneCode
        param["phoneno"] = phoneNo
        param["email"] = email
        param["verification_code"] = otp
        param["device_token"] = DEFAULTS.value(forKey: DEFAULTS_KEY.FCM_TOKEN) as? String ?? ""
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.VERIFY_USER, parameters: param, headers: nil) { responseObj in
            let resObj = responseObj as? [String:Any] ?? [String:Any]()
            print(resObj)
            
            let responseModel = ResponseDataModel(responseObj: resObj)
            
            if responseModel.success {
                
                let dataObj = resObj["data"] as? [String:Any] ?? [String:Any]()
                AppPrefsManager.sharedInstance.saveUserAccessToken(token: dataObj["access_token"] as? String ?? "")
                AppPrefsManager.sharedInstance.setIsUserLogin(isUserLogin: true)
                AppPrefsManager.sharedInstance.saveUserData(userData: dataObj["user"] as? [String:Any] ?? [String:Any]())
                self.goToTabBar()
            }
            
            Utility.shared.showToast(responseModel.message)
            
        } failure: { (error) in
            print(error.localizedDescription)
            return true
        }
        
        
        //        apimanager.callMultiPartDataWebServiceNew(type: LoginUserModel.self, image: nil, to: API.VERIFY_USER, params: param) { userModel, statusCode in
        //            print("statusCode == == ",statusCode)
        //            print(userModel)
        //            if statusCode != 201 && statusCode != 200 {
        //                self.showAlert(withTitle: "Error!", message: userModel?.message ?? "")
        //            } else {
        //                print(userModel)
        //                Utility.shared.storeUserData(model: userModel?.data?.user)
        //                DispatchQueue.main.async {
        //                    self.window?.setTabAsRoot()
        //                }
        //            }
        //        } failure: { error, statusCode in
        //            print(error.localizedDescription)
        //        }
    }
    
    func resendOtpAPI() {
        SVProgressHUD.show()
        view.endEditing(true)
        let param = [
            "countrycode":countryCode,
            "phonecode":phoneCode,
            "phoneno":phoneNo,
            "type":"phone"
        ]
        
        apimanager.callMultiPartDataWebServiceNew(type: ReSendOTPBaseModel.self, image: nil, to: API.RESEND_OTP, params: param) { userModel, statusCode in
            SVProgressHUD.dismiss()
            print("statusCode == == ",statusCode)
            print(userModel)
            if statusCode != 201 && statusCode != 200 {
                self.showAlert(withTitle: "Error!", message: userModel?.message ?? "")
            } else {
                
                self.tapResendTimer()
                print(userModel)
            }
        } failure: { error, statusCode in
            //print(error.localizedDescription)
        }
    }
    
    
    func verifyOTPForForgotPasswordAPI() {
        showLoader()
        paramDic["verification_code"] = otp
        view.endEditing(true)
        
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.VERIFY_OTP, parameters: paramDic, headers: nil) { responseObj in
            let resObj = responseObj as? [String:Any] ?? [String:Any]()
            print(resObj)
            
            let responseModel = ResponseDataModel(responseObj: resObj)
            
            if responseModel.success {
                let vc = ResetPasswordViewController.viewcontroller()
                
                vc.paramDic = self.paramDic
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            } else {
                Utility.shared.showToast(responseModel.message)
            }
            
            self.hideLoader()
            
        } failure: { (error) in
            Utility.shared.showToast(error.localizedDescription)
            return true
        }
        
        
        
    }
}

struct ReSendOTPBaseModel: Codable {
    
    let data : DataModel?
    let success : Bool?
    let message : String?
    
    enum CodingKeys: String, CodingKey {
        case message = "message"
        case success = "success"
        case data = "data"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        success = try values.decodeIfPresent(Bool.self, forKey: .success)
        data = try values.decodeIfPresent(DataModel.self, forKey: .data)
    }
}

struct DataModel: Codable {
    
    let verification_code : String?
    
    enum CodingKeys: String, CodingKey {
        case verification_code = "verification_code"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        verification_code = try values.decodeIfPresent(String.self, forKey: .verification_code)
    }
}

//MARK:- EXTENSION DPOTPVIEW

extension OTPViewController : DPOTPViewDelegate {
    func dpOTPViewAddText(_ text: String, at position: Int) {
        print("addText:- " + text + " at:- \(position)" )
        if text.count == 4 {
            otp = text
            if self.isFromForgotPassword {
                if Reachability.isConnectedToNetwork(){
                    self.verifyOTPForForgotPasswordAPI()
                }
                print("Done ----- forgot")
            } else {
                print("Done ----- verify")
                if Reachability.isConnectedToNetwork(){
//                    self.verifyAPI()
                    self.goToTabBar()
                }
            }
        }
        print(text)
        let arrOtp = text.map {String($0)}
        txtOtps.enumerated().forEach { index, txt in
            if text.count > index {
                txt.text = arrOtp[index]
            } else {
                txt.text = ""
            }
        }
    }
    
    func dpOTPViewRemoveText(_ text: String, at position: Int) {
        print("removeText:- " + text + " at:- \(position)" )
    }
    
    func dpOTPViewChangePositionAt(_ position: Int) {
        print("at:-\(position)")
    }
    
    func dpOTPViewBecomeFirstResponder() {
        print()
    }
    
    func dpOTPViewResignFirstResponder() {
        
    }
}
