//
//  PopupViewController.swift
//  CoachCulture
//
//  Created by Mayur Boghani on 26/10/21.
//

import UIKit

class PopupViewController: UIViewController {
    
    static func viewcontroller() -> PopupViewController {
        let vc = UIStoryboard(name: "Coach", bundle: nil).instantiateViewController(withIdentifier: "PopupViewController") as! PopupViewController
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        return vc
    }
    
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var doneImg: UIImageView!
    @IBOutlet weak var btnOk: UIButton! {
        didSet {
            btnOk.addTarget(self, action: #selector(didTapOK(_:)), for: .touchUpInside)
        }
    }
    var message = ""
    var dismissHandler: (() -> Void)?
    var isHide = false

    override func viewDidLoad() {
        super.viewDidLoad()
        doneImg.isHidden = isHide
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .center
        let attrString = NSMutableAttributedString(string: message, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .heavy), .foregroundColor: COLORS.TEXT_COLOR])
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
        lblMessage.attributedText = attrString
    }

    @objc func didTapOK(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            self.dismissHandler?()
        })
    }
}
