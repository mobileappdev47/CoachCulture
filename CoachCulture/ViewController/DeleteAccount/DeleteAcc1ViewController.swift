//
//  DeleteAcc1ViewController.swift
//  CoachCulture
//
//  Created by MAC on 20/07/22.
//

import UIKit
import KMPlaceholderTextView

class DeleteAcc1ViewController: BaseViewController {

    static func viewcontroller() -> DeleteAcc1ViewController {
            let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "DeleteAcc1ViewController") as! DeleteAcc1ViewController
            return vc
        }
        
        static func viewcontrollerNav() -> UINavigationController {
            let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "DeleteAcc1ViewController") as! UINavigationController
            return vc
        }
    
    @IBOutlet weak var lblCharCount: UILabel!
    @IBOutlet weak var txtDescription: KMPlaceholderTextView!
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    @IBOutlet weak var btn5: UIButton!
    @IBOutlet weak var imgDesErr: UIImageView!
    

    var reason : String = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblCharCount.text = "\(txtDescription.text.count)" + "/1000"
        txtDescription.delegate = self
    }
    
    //MARK: Click events
    
    @IBAction func clickTobBtnBack(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func clickToSelectOption(_ sender: UIButton) {
        btn1.backgroundColor = UIColor(red: 45/255.0, green: 58/255.0, blue: 76/255.0, alpha: 1.0)
        btn2.backgroundColor = UIColor(red: 45/255.0, green: 58/255.0, blue: 76/255.0, alpha: 1.0)
        btn3.backgroundColor = UIColor(red: 45/255.0, green: 58/255.0, blue: 76/255.0, alpha: 1.0)
        btn4.backgroundColor = UIColor(red: 45/255.0, green: 58/255.0, blue: 76/255.0, alpha: 1.0)
        btn5.backgroundColor = UIColor(red: 45/255.0, green: 58/255.0, blue: 76/255.0, alpha: 1.0)

        sender.backgroundColor = UIColor(red: 172/255.0, green: 186/255.0, blue: 202/255.0, alpha: 1.0)
        reason = sender.currentTitle!

        
    }
        
        
    @IBAction func clickTobBtnNext(_ sender: UIButton) {
       
        if (reason.count > 0)
        {
            let nextViewController = DeleteAcc2ViewController.viewcontroller()
            nextViewController.deleted_reason = reason
            nextViewController.deleted_description = txtDescription.text.trim()
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
        else
        {
            Utility.shared.showToast("Please select reason")

        }
       
    }

    
}

// MARK: - UITextViewDelegate
extension DeleteAcc1ViewController : UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let finalString = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        if finalString.count < 1000 {
                      
            lblCharCount.text = "\(finalString.count)" + "/1000"
            return true
        } else {
            return false
        }
        
       
    }
    
}

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}
