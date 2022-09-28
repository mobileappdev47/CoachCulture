//
//  PayMentConfirmationViewController.swift
//  CoachCulture
//
//  Created by mac on 05/07/1944 Saka.
//

import UIKit

class PayMentConfirmationViewController: UIViewController {

    var coachIDForPaymentWV = Int()
    var classIDForPaymentWV = Int()
    var coachCulture = "CoachCulture."
    var isClass: Bool = false
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDisctiption: UILabel!
    
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    
    static func viewcontroller() -> PayMentConfirmationViewController {
        let vc = UIStoryboard(name: "Followers", bundle: nil).instantiateViewController(withIdentifier: "PayMentConfirmationViewController") as! PayMentConfirmationViewController
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lblTitle.text = "You're about to leave the app and go to an external website. You will no longer be transacting with Apple."
        lblDisctiption.text = "Any accounts or purchases made outside of this app will be managed by the developer \(coachCulture) Your App Storeaccount , stored payment methods , and related features , such as subscription management and refund requests , will not be available . Apple is not responsible for"
        // Do any additional setup after loading the view.
    }
    
   
    @IBAction func btnContinueAction(_ sender: UIButton) {
        if isClass {
            let vc = PaymentWebViewController.viewcontroller()
            let webUrl = "http://admin.coachculture.com/api/auth/weblogin/\(classIDForPaymentWV)" //"http://admin.coachculture.com/api/payment/pay-amount/\(AppPrefsManager.sharedInstance.getUserData().id)/\(classIDForPaymentWV)"
            vc.isClass = isClass
            vc.classID = classIDForPaymentWV
            
            if let url = URL(string: webUrl), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
            
            dismiss(animated: true, completion: nil)
//            vc.modalPresentationStyle = .fullScreen
//            present(vc, animated: false, completion: nil)
        } else {
            let vc = PaymentWebViewController.viewcontroller()
            let webUrl = "http://admin.coachculture.com/api/auth/weblogin/\(coachIDForPaymentWV)" //"http://admin.coachculture.com/api/payment/pay-amount/\(AppPrefsManager.sharedInstance.getUserData().id)/\(coachIDForPaymentWV)"
            vc.coachID = coachIDForPaymentWV
            if let url = URL(string: webUrl), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
//            vc.modalPresentationStyle = .fullScreen
//            present(vc, animated: false, completion: nil)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func btnCancelAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
