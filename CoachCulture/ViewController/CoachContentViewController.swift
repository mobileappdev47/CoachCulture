//
//  CoachContentViewController.swift
//  CoachCulture
//
//  Created by Mayur Boghani on 28/10/21.
//

import UIKit

class CoachContentViewController: UIViewController {
    
    static func viewcontroller() -> CoachContentViewController {
        let vc = UIStoryboard(name: "Coach", bundle: nil).instantiateViewController(withIdentifier: "CoachContentViewController") as! CoachContentViewController
        return vc
    }
    
    @IBOutlet weak var btnOnDemand: UIButton!
    @IBOutlet weak var btnSchedule: UIButton!
    @IBOutlet weak var btnCreateMeal: UIButton!
    @IBOutlet weak var btnUsePrevious: UIButton!
    @IBOutlet weak var btnSubscribe: UIButton!
    
    var btnTitles = ["On Demand Video Upload",
                     "Schedule Live Videos",
                     "Create Meal Recipe",
                     "Use Previous Uploads as Template",
                     "Subscribers"]

    override func viewDidLoad() {
        super.viewDidLoad()

        [btnOnDemand,
        btnSchedule,
        btnCreateMeal,
        btnUsePrevious,
        btnSubscribe].enumerated().forEach { index, btn in
            btn?.setTitle(btnTitles[index], for: .normal)
            btn?.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        }
    }

}
