//
//  TabbarViewController.swift
//  CoachCulture
//
//  Created by Mayur Boghani on 29/10/21.
//

import UIKit

class TabbarViewController: UITabBarController {
    
    static func viewcontroller() -> TabbarViewController {
        let vc = UIStoryboard(name: "Coach", bundle: nil).instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.isTranslucent = false
        self.tabBar.tintColor = COLORS.THEME_RED
//        self.tabBar.barTintColor = COLORS.TEXT_COLOR
        self.tabBar.backgroundColor = COLORS.TABBAR_COLOR
        self.tabBar.unselectedItemTintColor = COLORS.TEXT_COLOR
    }
    

}
