//
//  SettingsViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 02/12/21.
//

import UIKit

class SettingsViewController: BaseViewController {
    
    static func viewcontroller() -> SettingsViewController {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        return vc
    }
    
    static func viewcontrollerNav() -> UINavigationController {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "SettingsNavVC") as! UINavigationController
        return vc
    }
    
    var logOutView:LogOutView!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showTabBar()
    }
    
    
    func setUpUI() {
        hideTabBar()
        
        logOutView = Bundle.main.loadNibNamed("LogOutView", owner: nil, options: nil)?.first as? LogOutView
        logOutView.tapToBtnLogOut {
            self.removeCountryView()
            AppPrefsManager.sharedInstance.setIsUserLogin(isUserLogin: false)
            let Login = LandingVC.viewcontroller()
           
            self.navigationController?.pushViewController(Login, animated: false)

            
//            let redViewController = LandingVC.viewcontroller()
//            let navigationController = UINavigationController(rootViewController: redViewController)
//            navigationController.isNavigationBarHidden = true
//            AppDelegate.shared().window?.rootViewController = navigationController
            
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
    
    
    // MARK: - Click Events
    @IBAction func clickToBtnLogout(_ sender: UIButton) {
        setCountryView()
    }
    
    @IBAction func clickToBtnEditProfile(_ sender: UIButton) {
        
        if AppPrefsManager.sharedInstance.getUserRole() ==  UserRole.coach {
            let vc = EditProfileViewController.viewcontroller()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            let vc = EditCoachProfileViewController.viewcontroller()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @IBAction func clickToBtnPaymentMethods(_ sender: UIButton) {
        let vc = PaymentMethodViewController.viewcontroller()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func clickToBtnPreviousClasses(_ sender: UIButton) {
        let vc = PreviousClassesViewController.viewcontroller()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func clickToBtnBookmarkClasses(_ sender: UIButton) {
        let vc = PreviousClassesViewController.viewcontroller()
        vc.isFromBookMarkPage = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func clickToBtnDownlaodedClass(_ sender: UIButton) {
        let vc = DownloadedClassViewController.viewcontroller()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
