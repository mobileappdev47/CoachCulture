//
//  OTPViewController.swift
//  CoachCulture
//
//  Created by Mayur Boghani on 29/10/21.
//

import UIKit

class OTPViewController: BaseViewController {
    
    static func viewcontroller() -> OTPViewController {
        let vc = UIStoryboard(name: "Coach", bundle: nil).instantiateViewController(withIdentifier: "OTPViewController") as! OTPViewController
        return vc
    }
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var btnResend: UIButton!
    @IBOutlet weak var btnChangeNumber: UIButton!
    @IBOutlet weak var btnCounter: UIButton!

    @IBOutlet var btnDigits: [UIButton]!
    @IBOutlet var txtOtps: [UILabel]!
    var countryCode = ""
    var phoneCode = ""
    var phoneNo = ""
    var username = ""
    var password = ""
    var otp = ""
    var verifiedCallback: (() -> Void)?
    var verifyotp = "1234"
    let apimanager = ApiManager()
    var counter = 60
    var timer = Timer()
    var isFromForgotPassword = false
    var emaiOrPhone = ""
    
    var paramDic = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnResend.addTarget(self, action: #selector(didTapResend(_:)), for: .touchUpInside)
        btnChangeNumber.addTarget(self, action: #selector(didTapChangeNumber(_:)), for: .touchUpInside)
        btnDigits.forEach { btn in
            btn.addTarget(self, action: #selector(didTapDigit(_:)), for: .touchUpInside)
        }
        
        btnResend.setTitle("Resent OTP", for: .normal)
        btnChangeNumber.setTitle("Change Number", for: .normal)
        btnResend.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btnChangeNumber.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        if isFromForgotPassword {
            lblDesc.text = "Please type the verification code sent to \(emaiOrPhone)"
        } else {
            lblDesc.text = "Please type the verification code sent to \(phoneCode) \(phoneNo)"
        }
        
        
        tapResendTimer()
    }
    
    fileprivate func tapResendTimer() {
        btnCounter.isHidden = false
        self.btnResend.isEnabled = false
        btnCounter.setTitle("00:60", for: .normal)
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc func update() {
        if(counter > 0) {
            let minutes = String(counter / 60)
            let seconds = String(counter % 60)
            if Int(seconds)! < 10 {
                btnCounter.setTitle("0\(minutes)" + ":" + "0\(seconds)", for: .normal)
            } else {
                btnCounter.setTitle("0\(minutes)" + ":" + seconds, for: .normal)
            }
            counter -= 1
        } else {
            self.timer.invalidate()
            self.btnCounter.isHidden = true
            self.btnResend.isEnabled = true
        }
    }

    @objc func didTapDigit(_ sender: UIButton) {
        if sender.tag == 10 {
            if otp.count > 0 {
                otp = String(otp.prefix(otp.count - 1))
            }
        } else {
            if otp.count < 4 {
                let digit = sender.tag
                otp.append("\(digit)")
                if otp.count == 4 {
                    if verifyotp == otp {
                        print("Done -----")
                        if self.isFromForgotPassword {
                            self.verifyOTPForForgotPasswordAPI()
                        } else {
                            self.verifyAPI()
                        }
                        
                    } else {
                        print("Alert ------ ")
                    }
                }
            } else if otp.count == 4 {
                if verifyotp == otp {
                    print("Done -----")
                } else {
                    print("Alert ------ ")
                }
            }
        }
        print(otp)
        let arrOtp = otp.map {String($0)}
        txtOtps.enumerated().forEach { index, txt in
            if otp.count > index {
                txt.text = arrOtp[index]
            } else {
                txt.text = ""
            }
        }
    }
    
    @objc func didTapChangeNumber(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapResend(_ sender: UIButton) {
        tapResendTimer()
    }
}

//MARK: - EXTENSION API CALL
extension OTPViewController {
    
    func verifyAPI() {
        
        let param = [
            "username": username,
            "password": password,
            "countrycode":countryCode,
            "phonecode":phoneCode,
            "phoneno":phoneNo,
            "verification_code": otp
        ]
        
        
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.VERIFY_USER, parameters: param, headers: nil) { responseObj in
              let resObj = responseObj as? [String:Any] ?? [String:Any]()
            print(resObj)
            
            let responseModel = ResponseDataModel(responseObj: resObj)
            
            if responseModel.success {
                
                let dataObj = resObj["data"] as? [String:Any] ?? [String:Any]()
                AppPrefsManager.sharedInstance.saveUserAccessToken(token: dataObj["access_token"] as? String ?? "")
                AppPrefsManager.sharedInstance.setIsUserLogin(isUserLogin: true)
                self.goToTabBar()
            }
            
            Utility.shared.showToast(responseModel.message)
            
           
              
          } failure: { (error) in
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
        
        let param = [
            "username": username,
            "password": password,
            "countrycode":countryCode,
            "phonecode":phoneCode,
            "phoneno":phoneNo,
            "verification_code": otp
        ]
        
        apimanager.callMultiPartDataWebServiceNew(type: SignupUserModel.self, image: nil, to: API.VERIFY_USER, params: param) { userModel, statusCode in
            print("statusCode == == ",statusCode)
            print(userModel)
            if statusCode != 201 && statusCode != 200 {
                self.showAlert(withTitle: "Error!", message: userModel?.message ?? "")
            } else {
                print(userModel)
            }
        } failure: { error, statusCode in
            print(error.localizedDescription)
        }
    }
    
    
    func verifyOTPForForgotPasswordAPI() {
                showLoader()
        paramDic["verification_code"] = otp
        
        
        
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
                
            }
            
            self.hideLoader()
              
          } failure: { (error) in
              return true
          }
        
        

    }
}
