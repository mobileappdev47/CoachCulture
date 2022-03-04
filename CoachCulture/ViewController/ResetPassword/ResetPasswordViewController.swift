//
//  ResetPasswordViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 01/12/21.
//

import UIKit

class ResetPasswordViewController: BaseViewController {
    
    static func viewcontroller() -> ResetPasswordViewController {
        let vc = UIStoryboard(name: "Coach", bundle: nil).instantiateViewController(withIdentifier: "ResetPasswordViewController") as! ResetPasswordViewController
        return vc
    }
    
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtCPassword: UITextField!

    let txtPlaceholders = ["New Password",  "Retype New Password"]
    
    var paramDic = [String:Any]()


    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
    }
    
    func setUpUI() {
        
        
        [txtNewPassword,
         txtCPassword,
         
         ].enumerated().forEach { index, txt in
            let place = txtPlaceholders[index]
            txt?.attributedPlaceholder = NSAttributedString(string: place, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor: COLORS.TEXT_COLOR])
            txt?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            txt?.textColor = COLORS.TEXT_COLOR
            txt?.tintColor = COLORS.TEXT_COLOR
            
            txt?.layer.cornerRadius = 10
            txt?.clipsToBounds = true
        }
    }
    
    @IBAction func clickToBtnSubmit(_ sender: UIButton) {
        
        if (txtNewPassword.text!.isEmpty) {
           self.showAlert(withTitle: "Invalid Password", message: "Please enter valid password")
        } else if (txtNewPassword.text! != txtCPassword.text!) {
            self.showAlert(withTitle: "Invalid Retyped Password", message: "Please enter valid password")
        } else {
            if Reachability.isConnectedToNetwork(){
                changePassword()
            }
        }
        
    }

}


extension ResetPasswordViewController {
    
    func changePassword() {
        showLoader()
        paramDic["password"] = txtNewPassword.text!
                
      _ =  ApiCallManager.requestApi(method: .post, urlString: API.RESET_PASSWORD, parameters: paramDic, headers: nil) { responseObj in
            let resObj = responseObj as? [String:Any] ?? [String:Any]()
          print(resObj)
          
          let responseModel = ResponseDataModel(responseObj: resObj)
          
          if responseModel.success {
              
              self.navigationController?.popToRootViewController(animated: true)
          }
          
          Utility.shared.showToast(responseModel.message)
          self.hideLoader()
            
        } failure: { (error) in
            return true
        }
    }
}
