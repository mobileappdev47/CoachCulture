//
//  CustomTabBarController.swift
//  FitProHub
//
//  Created by Sunil Zalavadiya on 07/05/18.
//  Copyright © 2018 Sunil Zalavadiya. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController
{
    //MARK: - All variables
    var customTabBarView: CustomTabBarView!
    var forceHideTabBar = false

    //MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK: - All methods
    private func setupUI()
    {
        customTabBarView = Bundle.main.loadNibNamed("CustomTabBarView", owner: nil, options: nil)!.first as? CustomTabBarView
        customTabBarView.delegate = self
        
        self.view.addSubview(customTabBarView)
        
        customTabBarView.btnTabHeightConstraint.constant = self.tabBar.frame.size.height
        
        var tabBarHeight = self.tabBar.frame.size.height
        if #available(iOS 11.0, *)
        {
            if ((UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0.0) > CGFloat(0.0))
            {
                tabBarHeight = tabBarHeight + (UIApplication.shared.keyWindow!.safeAreaInsets.bottom)//iPhone x tab bar height
            }
        }
        
        customTabBarView.translatesAutoresizingMaskIntoConstraints = false
        
        customTabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0.0).isActive = true
        customTabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0).isActive = true
        customTabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0).isActive = true
        customTabBarView.heightAnchor.constraint(equalToConstant: tabBarHeight).isActive = true
        
        self.view.layoutIfNeeded()
        
        setupViewControllers()
        
        if forceHideTabBar
        {
            self.tabBar.isHidden = true
            self.customTabBarView.isHidden = true
        }
    }
    
    private func setupViewControllers()
    {
        var viewControllers = [AnyObject]()
        
        let navController1: UINavigationController = PopularCoachRecipeViewController.viewcontrollerNav()
        let navController2: UINavigationController = YourCoachesViewController.viewcontrollerNav()
        let navController3: UINavigationController = HomeViewController.viewcontrollerNav()
        let navController4: UINavigationController = MainSearchViewController.viewcontrollerNav()
        let navController5: UINavigationController = CoachClassProfileViewController.viewcontrollerNav()
                
        viewControllers = [navController1, navController2, navController3, navController4, navController5]
        
        self.viewControllers = viewControllers as? [UIViewController];
        
        customTabBarView.selectTabAt(index: 2)
    }
    
    func tabBarHidden() -> Bool
    {
        return customTabBarView.isHidden && self.tabBar.isHidden
    }
    
    func setTabBarHidden(tabBarHidden: Bool, vc: UIViewController?)
    {
        if(tabBarHidden)
        {
            self.tabBar.isHidden = true
            self.customTabBarView.isHidden = tabBarHidden
            
            vc?.edgesForExtendedLayout = UIRectEdge.bottom
            
        }
        else
        {
            if !forceHideTabBar
            {
                self.tabBar.isHidden = true
                self.customTabBarView.isHidden = tabBarHidden
                
                vc?.edgesForExtendedLayout = UIRectEdge.top
                
            }
            
        }
    }

    //MARK: -
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: - CustomTabBarViewDelegate
extension CustomTabBarController: CustomTabBarViewDelegate
{
    func tabSelectedAtIndex(tabIndex: Int)
    {
        let selectedVC =  self.viewControllers![tabIndex]
        
        selectedIndex = tabIndex
        
        if (self.selectedViewController == selectedVC)
        {
            let navVc = self.selectedViewController as! UINavigationController
            navVc.popToRootViewController(animated: true)
        }
        
        super.selectedViewController = selectedViewController
    }
}
