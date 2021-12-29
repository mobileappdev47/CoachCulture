//
//  CoachContentEditViewController.swift
//  CoachCulture
//
//  Created by Mayur Boghani on 28/10/21.
//

import UIKit

class CoachContentEditViewController: UIViewController {
    
    static func viewcontroller() -> CoachContentEditViewController {
        let vc = UIStoryboard(name: "Coach", bundle: nil).instantiateViewController(withIdentifier: "CoachContentEditViewController") as! CoachContentEditViewController
        return vc
    }
    
    @IBOutlet weak var btnSegCoachContent: UIButton!
    @IBOutlet weak var btnSegEditProfile: UIButton!
    
    @IBOutlet weak var viewCoachContent: UIView!
    @IBOutlet weak var viewEditProfile: UIView!
    
    @IBOutlet weak var viewSegment: UIView!
    @IBOutlet weak var underLine: UIView!
    var leadingA: NSLayoutConstraint!
    var trailingA: NSLayoutConstraint!
    
    @IBOutlet weak var btnBack: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        btnSegCoachContent.addTarget(self, action: #selector(didTapSegCoachContent(_:)), for: .touchUpInside)
        btnSegEditProfile.addTarget(self, action: #selector(didTapSegEditProfile(_:)), for: .touchUpInside)
        viewCoachContent.isHidden = false
        viewEditProfile.isHidden = true
        leadingA = underLine.leadingAnchor.constraint(equalTo: btnSegCoachContent.leadingAnchor)
        trailingA = underLine.trailingAnchor.constraint(equalTo: btnSegCoachContent.trailingAnchor)
        leadingA.isActive = true
        trailingA.isActive = true
        btnBack.setTitle("", for: .normal)
        btnBack.setImage(UIImage(named: "ic_back"), for: .normal)
    }
    
    @objc func didTapSegCoachContent(_ sender: UIButton) {
        viewCoachContent.isHidden = false
        viewEditProfile.isHidden = true
        leadingA.isActive = false
        trailingA.isActive = false
        leadingA = underLine.leadingAnchor.constraint(equalTo: btnSegCoachContent.leadingAnchor)
        trailingA = underLine.trailingAnchor.constraint(equalTo: btnSegCoachContent.trailingAnchor)
        leadingA.isActive = true
        trailingA.isActive = true
        UIView.animate(withDuration: 0.3) {
            self.viewSegment.layoutIfNeeded()
        }
    }
    
    @objc func didTapSegEditProfile(_ sender: UIButton) {
        viewCoachContent.isHidden = true
        viewEditProfile.isHidden = false
        leadingA.isActive = false
        trailingA.isActive = false
        leadingA = underLine.leadingAnchor.constraint(equalTo: btnSegEditProfile.leadingAnchor)
        trailingA = underLine.trailingAnchor.constraint(equalTo: btnSegEditProfile.trailingAnchor)
        leadingA.isActive = true
        trailingA.isActive = true
        UIView.animate(withDuration: 0.3) {
            self.viewSegment.layoutIfNeeded()
        }
    }

}
