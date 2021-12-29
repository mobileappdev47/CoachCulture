//
//  SignupCoachEmbedViewController.swift
//  CoachCulture
//
//  Created by Mayur Boghani on 28/10/21.
//

import UIKit

class SignupCoachEmbedViewController: UIViewController {

    static func viewcontroller() -> SignupCoachEmbedViewController {
        let vc = UIStoryboard(name: "Coach", bundle: nil).instantiateViewController(withIdentifier: "SignupCoachEmbedViewController") as! SignupCoachEmbedViewController
        return vc
    }
    
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtBirthDate: UITextField!
    @IBOutlet weak var txtNationality: UITextField!
    @IBOutlet weak var txtPassport: UITextField!
    @IBOutlet weak var txtUploadPicture: UITextField!
    
    @IBOutlet weak var txtDate: UITextField!
    @IBOutlet weak var txtMonth: UITextField!
    @IBOutlet weak var txtYear: UITextField!
    
    @IBOutlet weak var btnSubmit: UIButton! {
        didSet {
            btnSubmit.addTarget(self, action: #selector(didTapSubmit(_:)), for: .touchUpInside)
        }
    }
    let dropDownNationality = DropDown()
    var birthdate = ""
    var imgPassportData = Data()
    
    var txtImages = ["ic_signup_profile",
                     "ic_signup_profile",
                     "ic_email",
                     "ic_birthdate",
                     "ic_nationality",
                     "ic_passport",
                     "ic_upload_doc",
                     "",
                     "",
                     ""
    ]
    
    var txtPlaceholders = ["First Name",
                           "Last Name",
                           "Email Address",
                           "Birthday",
                           "Nationality",
                           "Passport/ID Number",
                           "Upload Picture of Passport or ID",
                           "DD",
                           "MM",
                           "YYYY"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        configureDropDown()
    }
    
    func configureDropDown() {
        DropDown.appearance().textColor = COLORS.TEXT_COLOR
        DropDown.appearance().selectionBackgroundColor = COLORS.TEXTFIELD_COLOR
        DropDown.appearance().textFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        DropDown.appearance().backgroundColor = COLORS.VIEW_BG_COLOR
        DropDown.appearance().cellHeight = 40
        DropDown.appearance().separatorColor = COLORS.TEXTFIELD_COLOR

        
        dropDownNationality.direction = .bottom
        dropDownNationality.anchorView = txtNationality
        dropDownNationality.bottomOffset = CGPoint(x: 0, y: txtNationality.bounds.height)
        dropDownNationality.dataSource = ["Germany", "India", "France", "United States", "United Kingdom", "Ireland"]
        dropDownNationality.selectionAction = { [unowned self] (index: Int, item: String) in
          print("Selected item: \(item) at index: \(index)")
            self.txtNationality.text = item
        }
    }
    
    fileprivate func setupViews() {
        [txtFirstName,
         txtLastName,
         txtEmail,
         txtBirthDate,
         txtNationality,
         txtPassport,
         txtUploadPicture,
         txtDate,
         txtMonth,
         txtYear].enumerated().forEach { index, txt in
            let img = txtImages[index]
            let place = txtPlaceholders[index]
            
            if img != "" {
                let leftvw = UIView(frame: CGRect(x: 0, y: 0, width: 54, height: 30))
                let imgView = UIImageView(frame: CGRect(x: 12, y: 0, width: 30, height: 30))
                imgView.image = UIImage(named: img)
                imgView.contentMode = .center
                leftvw.addSubview(imgView)
                txt?.leftView = leftvw
                txt?.leftViewMode = .always
            }
            //            txt?.placeholder = place
            txt?.attributedPlaceholder = NSAttributedString(string: place, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: (index == 7 || index == 8 || index == 9) ? 16 : 18, weight: .bold), .foregroundColor: COLORS.TEXT_COLOR])
            txt?.font = UIFont.systemFont(ofSize: (index == 7 || index == 8 || index == 9) ? 16 : 18, weight: .bold)
            txt?.textColor = COLORS.TEXT_COLOR
            txt?.tintColor = COLORS.TEXT_COLOR
            
            txt?.layer.cornerRadius = 10
            txt?.clipsToBounds = true
        }
        btnSubmit.setTitle("Submit", for: .normal)
        btnSubmit.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        txtNationality.delegate = self
        txtUploadPicture.delegate = self
        
        txtBirthDate.setInputViewDatePicker(target: self, selector: #selector(doneDatePicker))
    }
    
    @objc func doneDatePicker() {
        if let datePicker = self.txtBirthDate.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateStr = dateFormatter.string(from: datePicker.date)
            let datee = dateStr.components(separatedBy: "-")
            let date = datee[2]
            let month = datee[1]
            let year = datee[0]
            txtDate.text = date
            txtMonth.text = month
            txtYear.text = year
            birthdate = dateStr
        }
        self.txtBirthDate.resignFirstResponder()
    }

    @objc func didTapSubmit(_ sender: UIButton) {
        if validation() {
            
        }
    }
    
    func showPopup() {
        let vc = PopupViewController.viewcontroller()
        vc.message = "We are excited that you want to be a part of the CoachCulture family. We are reviewing your documents and will come back to you via email within 24hrs."
        vc.dismissHandler = { [weak self] in
//            guard let self = self else {return}
//            let vc = CoachContentEditViewController.viewcontroller()
//            self.navigationController?.pushViewController(vc, animated: true)
        }
        self.present(vc, animated: true, completion: nil)
    }

    func validation() -> Bool {
        if txtFirstName.text!.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 ||
            txtLastName.text!.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 ||
            txtEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 ||
            birthdate.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 ||
            txtNationality.text!.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 ||
            txtPassport.text!.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 ||
            imgPassportData.count == 0 {
            self.showAlert(withTitle: "Empty Field", message: "Please enter all field")
            return false
        } else if !(txtEmail.text!.isValidEmail) {
            self.showAlert(withTitle: "Invalid Email", message: "Please enter valid email")
            return false
        } else {
            return true
        }
    }
    
}

extension SignupCoachEmbedViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtNationality {
            dropDownNationality.show()
        } else {
            
        }
        return false
    }
    
}
