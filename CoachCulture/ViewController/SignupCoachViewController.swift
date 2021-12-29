//
//  SignupCoachViewController.swift
//  CoachCulture
//
//  Created by Mayur Boghani on 26/10/21.
//

import UIKit


class SignupCoachViewController: UIViewController {
    
    static func viewcontroller() -> SignupCoachViewController {
        let vc = UIStoryboard(name: "Coach", bundle: nil).instantiateViewController(withIdentifier: "SignupCoachViewController") as! SignupCoachViewController
        return vc
    }
    
    @IBOutlet weak var viewSignup: UIView!
    @IBOutlet weak var viewEditProfile: UIView!
    
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var btnSegSignupCoach: UIButton!
    @IBOutlet weak var btnSegEditProfile: UIButton!
    
    @IBOutlet weak var viewSegment: UIView!
    @IBOutlet weak var underLine: UIView!
    var leadingA: NSLayoutConstraint!
    var trailingA: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSegSignupCoach.addTarget(self, action: #selector(didTapSegSignup(_:)), for: .touchUpInside)
        btnSegEditProfile.addTarget(self, action: #selector(didTapSegEditProfile(_:)), for: .touchUpInside)
        viewSignup.isHidden = false
        viewEditProfile.isHidden = true
        leadingA = underLine.leadingAnchor.constraint(equalTo: btnSegSignupCoach.leadingAnchor)
        trailingA = underLine.trailingAnchor.constraint(equalTo: btnSegSignupCoach.trailingAnchor)
        leadingA.isActive = true
        trailingA.isActive = true
        btnBack.setTitle("", for: .normal)
        btnBack.setImage(UIImage(named: "ic_back"), for: .normal)
    }
    
    //    @objc func didTapSubmit(_ sender: UIButton) {
    //        let vc = PopupViewController.viewcontroller()
    //        vc.modalPresentationStyle = .overCurrentContext
    //        vc.modalTransitionStyle = .crossDissolve
    //        vc.message = "We are excited that you want to be a part of the CoachCulture family. We are reviewing your documents and will come back to you via email within 24hrs."
    //        self.present(vc, animated: true, completion: nil)
    //    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @objc func didTapSegSignup(_ sender: UIButton) {
        viewSignup.isHidden = false
        viewEditProfile.isHidden = true
        leadingA.isActive = false
        trailingA.isActive = false
        leadingA = underLine.leadingAnchor.constraint(equalTo: btnSegSignupCoach.leadingAnchor)
        trailingA = underLine.trailingAnchor.constraint(equalTo: btnSegSignupCoach.trailingAnchor)
        leadingA.isActive = true
        trailingA.isActive = true
        UIView.animate(withDuration: 0.3) {
            self.viewSegment.layoutIfNeeded()
        }
    }
    
    @objc func didTapSegEditProfile(_ sender: UIButton) {
        viewSignup.isHidden = true
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
