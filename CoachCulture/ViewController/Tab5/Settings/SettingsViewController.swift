//
//  SettingsViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 02/12/21.
//

import UIKit
import GoogleSignIn
import MessageUI

class SettingsViewController: BaseViewController {
    
    static func viewcontroller() -> SettingsViewController {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        return vc
    }
    
    static func viewcontrollerNav() -> UINavigationController {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "SettingsNavVC") as! UINavigationController
        return vc
    }
    
    @IBOutlet weak var viwCreateCoachContent: UIView!
    
    var logOutView:LogOutView!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar()
    }
    
    
    func setUpUI() {
        
        logOutView = Bundle.main.loadNibNamed("LogOutView", owner: nil, options: nil)?.first as? LogOutView
        logOutView.tapToBtnLogOut {
            self.removeCountryView()
            GIDSignIn.sharedInstance.signOut()
            AppPrefsManager.sharedInstance.saveUserData(userData: [:])
            AppPrefsManager.sharedInstance.setIsUserLogin(isUserLogin: false)
            let Login = LandingVC.viewcontroller()
            self.navigationController?.pushViewController(Login, animated: false)
        }
        if AppPrefsManager.sharedInstance.getUserRole() !=  UserRole.coach {
            viwCreateCoachContent.isHidden = true
        }
    }
    
    func setCountryView(){
        
        logOutView.frame.size = self.view.frame.size
        
        self.view.addSubview(logOutView)
    }
    
    func removeCountryView(){
        if logOutView != nil{
            logOutView.removeFromSuperview()
        }
        
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@coachculture.com"])
            mail.setMessageBody("", isHTML: true)

            present(mail, animated: true)
        } else {
            Utility.shared.showToast("Mail service not available!")
        }
    }
    
    // MARK: - Click Events
    
    @IBAction func btnCustomerService(_ sender: UIButton) {
        sendEmail()
    }
    
    @IBAction func clickToBtnLogout(_ sender: UIButton) {
        hideTabBar()
        setCountryView()
    }
    
    @IBAction func clickToBtnCreateCoach(_ sender: UIButton) {
        hideTabBar()
        let vc = EditProfileViewController.viewcontroller()
        vc.isForEdit = false
        self.pushVC(To: vc, animated: true)
    }
    
    @IBAction func clickToBtnEditProfile(_ sender: UIButton) {
        hideTabBar()
        if AppPrefsManager.sharedInstance.getUserRole() ==  UserRole.coach {
            let vc = EditProfileViewController.viewcontroller()
            vc.isForEdit = true
            self.pushVC(To: vc, animated: true)
        }
        else {
            let vc = EditCoachProfileViewController.viewcontroller()
            self.pushVC(To: vc, animated: true)
        }        
    }
    
    @IBAction func clickToBtnPaymentMethods(_ sender: UIButton) {
        hideTabBar()
        let vc = PaymentMethodViewController.viewcontroller()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickToBtnBack(_ sender: UIButton) {
        self.popVC(animated: true)
    }
    
    @IBAction func clickToBtnPreviousClasses(_ sender: UIButton) {
        hideTabBar()
        let vc = PreviousClassesViewController.viewcontroller()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func clickToBtnBookmarkClasses(_ sender: UIButton) {
        hideTabBar()
        let vc = PreviousClassesViewController.viewcontroller()
        vc.isFromBookMarkPage = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func clickToBtnDownlaodedClass(_ sender: UIButton) {
        hideTabBar()
        let vc = DownloadedClassViewController.viewcontroller()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
