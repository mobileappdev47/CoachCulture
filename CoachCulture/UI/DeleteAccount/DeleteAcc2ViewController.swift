//
//  DeleteAcc2ViewController.swift
//  CoachCulture
//
//  Created by MAC on 20/07/22.
//

import UIKit

class DeleteAcc2ViewController: BaseViewController {

    
    static func viewcontroller() -> DeleteAcc2ViewController {
            let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "DeleteAcc2ViewController") as! DeleteAcc2ViewController
            return vc
        }
        
        static func viewcontrollerNav() -> UINavigationController {
            let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "DeleteAcc2ViewController") as! UINavigationController
            return vc
        }
    
    @IBOutlet weak var txtPasswordLogin: UITextField!
    @IBOutlet weak var imgErrPasswordLogin: UIImageView!
    @IBOutlet weak var viewPwdHeight: NSLayoutConstraint!
    @IBOutlet weak var imgPwd: UIImageView!

    //variables
    var apiParams = [String:Any]()
    var deleted_reason: String?
    var deleted_description: String?
    var login_type : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtPasswordLogin?.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor: COLORS.TEXT_COLOR])
        txtPasswordLogin?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        txtPasswordLogin?.textColor = COLORS.TEXT_COLOR
        txtPasswordLogin?.tintColor = COLORS.TEXT_COLOR
        txtPasswordLogin?.delegate = self
        //txt?.layer.cornerRadius = 10
        txtPasswordLogin?.clipsToBounds = true
        login_type = DEFAULTS.value(forKey: DEFAULTS_KEY.LOGIN_TYPE) as? String
        if (login_type == "0")
        {
            viewPwdHeight.constant = 50
            imgPwd.isHidden = false
        }
        else
        {
            viewPwdHeight.constant = 0
            imgPwd.isHidden = true
        }
    }
    

    //MARK: Click events
    @IBAction func clickTobBtnBack(_ sender: UIButton) {
       
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func clickTobBtnNext(_ sender: UIButton) {
        txtPasswordLogin.resignFirstResponder()
        if txtPasswordLogin.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            txtPasswordLogin.setError("Password is mandatory field", show: true)
            imgErrPasswordLogin.isHidden = false
        } else {
            txtPasswordLogin.setError()
            imgErrPasswordLogin.isHidden = true
            if (login_type == "0")
            {
                apiParams = [
                    "deleted_reason": deleted_reason!,
                    "deleted_description": deleted_description!,
                    "password": txtPasswordLogin.text?.trim() ?? ""
                ]
            }
            else
            {
                apiParams = [
                    "deleted_reason": deleted_reason!,
                    "deleted_description": deleted_description!,
                ]
            }
            
            if Reachability.isConnectedToNetwork(){
                delAccountAPI()
            }
        }
    }

}

extension DeleteAcc2ViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        txtPasswordLogin.setError()
        imgErrPasswordLogin.isHidden = true
        if textField == txtPasswordLogin {
            let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            txtPasswordLogin.text = ""
            txtPasswordLogin.text = newText
            return false
        }
        return true
    }
    
    fileprivate func resetAppData() {
        AppPrefsManager.sharedInstance.saveUserData(userData: [:])
        AppPrefsManager.sharedInstance.setIsUserLogin(isUserLogin: false)
        if let isRememberMe = DEFAULTS.value(forKey: DEFAULTS_KEY.IS_REMEMBER_ME) as? Bool, !isRememberMe {
            DEFAULTS.setValue("", forKey: DEFAULTS_KEY.USERNAME)
            DEFAULTS.setValue("", forKey: DEFAULTS_KEY.USER_PASSWORD)
            DEFAULTS.setValue(false, forKey: DEFAULTS_KEY.IS_REMEMBER_ME)
        }
    }
    
    func delAccountAPI() {
        showLoader()
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.DELETE_ACCOUNT, parameters: apiParams, headers: nil) { responseObj in
            let resObj = responseObj as? [String:Any] ?? [String:Any]()
            print(resObj)
            
            let responseModel = ResponseDataModel(responseObj: resObj)
            
            if responseModel.success {
                let dataObj = resObj["data"] as? [String:Any] ?? [String:Any]()
                Utility.shared.showToast("Account deleted successfully.")
                self.resetAppData()
                let Login = LandingVC.viewcontroller()
                self.navigationController?.pushViewController(Login, animated: false)

               
            } else {
               
                Utility.shared.showToast(responseModel.message)
            }
            self.hideLoader()
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
}
