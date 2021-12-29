//
//  YourCoachesViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 20/12/21.
//

import UIKit

class YourCoachesViewController: BaseViewController {
    
    static func viewcontroller() -> YourCoachesViewController {
        let vc = UIStoryboard(name: "Followers", bundle: nil).instantiateViewController(withIdentifier: "YourCoachesViewController") as! YourCoachesViewController
        return vc
    }
    
    static func viewcontrollerNav() -> UINavigationController {
        let vc = UIStoryboard(name: "Followers", bundle: nil).instantiateViewController(withIdentifier: "YourCoachesNavVc") as! UINavigationController
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
showTabBar()
    }
    
    // MARK: - CLICK EVENTS
    @IBAction func clickToBtnSearch( _ sender : UIButton) {
        let vc = SearchFollowersViewController.viewcontroller()
        self.navigationController?.pushViewController(vc, animated: true)
    }

}





