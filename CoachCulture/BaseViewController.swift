//
//  BaseViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 01/12/21.
//

import UIKit
import SVProgressHUD

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        hideLoader()
    }
    
    func showLoader() {
        SVProgressHUD.show()
    }
    
    func hideLoader() {
        SVProgressHUD.dismiss()
    }
    
    //MARK: - Tabbar
    func hideTabBar()
    {
        if let taskerCustomTabBar = self.tabBarController as? CustomTabBarController {
            taskerCustomTabBar.setTabBarHidden(tabBarHidden: true, vc: self)
        }
    }
    
    func showTabBar()
    {
        if let taskerCustomTabBar = self.tabBarController as? CustomTabBarController {
            taskerCustomTabBar.setTabBarHidden(tabBarHidden: false, vc: self)
        }
    }
    
    //MARK: - Home Page
    func goToTabBar() {
        let customTabBarController: CustomTabBarController = CustomTabBarController()
        navigationController?.pushViewController(customTabBarController, animated: true)
    }
    
    func goToPerticularTab(index: Int) {
        let vc = AppDelegate.shared().window?.rootViewController as! UINavigationController
        for temp in vc.viewControllers {
            if let tabbar  = temp as? CustomTabBarController {
                tabbar.customTabBarView.selectTabAt(index: index)
            }
        }
    }
    
    
    
}
