//
//  EditCoachProfileViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 04/12/21.
//

import UIKit
import MobileCoreServices

class EditCoachProfileViewController: BaseViewController {
    
    static func viewcontroller() -> EditCoachProfileViewController {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "EditCoachProfileViewController") as! EditCoachProfileViewController
        return vc
    }
    
    
    @IBOutlet weak var viwLine1: UIView!
    @IBOutlet weak var viwLine2: UIView!
    @IBOutlet weak var viwSignUpAsCoach: UIView!
    @IBOutlet weak var viwEditProfile: UIView!
    
    @IBOutlet weak var btnSignUpAsCoach: UIButton!
    @IBOutlet weak var btnEditProfile: UIButton!
    @IBOutlet weak var btnEditUserPhoto: UIButton!
    @IBOutlet weak var btnUploadPasswordIDPhoto: UIButton!
    @IBOutlet weak var btnCurrency: UIButton!
    @IBOutlet var btnMonthlyFeeQue: UIButton!
    @IBOutlet weak var btnAcCurrency: UIButton!
    
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPasswordIdNUmber: UITextField!
    @IBOutlet weak var txtDummyBOD: UITextField!
    
    @IBOutlet weak var txtProfileUserName: UITextField!
    @IBOutlet weak var txtProfilePhone: UITextField!
    @IBOutlet weak var txtProfileEmail: UITextField!
    @IBOutlet weak var txtProfilePassword: UITextField!
    @IBOutlet weak var txtProfileRetypePassword: UITextField!
    @IBOutlet weak var txtProfileCountryCode: UITextField!
    @IBOutlet weak var txtMonthlySubFee: UITextField!
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    @IBOutlet weak var lblPassportImageName: UILabel!
    @IBOutlet weak var lblNationality: UILabel!
    @IBOutlet weak var lblCurrency: UILabel!
    @IBOutlet weak var lblAcCurrency: UILabel!
    
    @IBOutlet weak var imgTermsCondition: UIImageView!
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var imgCountryCode: UIImageView!

    
    var customDatePickerForBirthDate:CustomDatePickerViewForTextFeild!
    
    var addPhotoPopUp:AddPhotoPopUp!
    var nationalityView : NationalityView!
//    var nationalityView1 : NationalityView!
    var successPopUpForCoachProfieView : SuccessPopUpForCoachProfieView!
    var dropDown = DropDown()
    var photoData:Data!
    var arrNationalityData = [NationalityData]()
    var dateOfBirth = ""
    var countryCodeDesc = ""
    var selectedButton = UIButton()
    var user_image = ""
    var userDataObj = UserData()
    var baseCurrency = "USD"
    var accountCurrency = ""
    var fromCurrency = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    // MARK: - methods
    func setUpUI() {
        clickToBtnSignUpAsCoach(btnSignUpAsCoach)
        
        imgUserProfile.applyBorder(3, borderColor: hexStringToUIColor(hex: "#CC2936"))
        imgUserProfile.addCornerRadius(5)
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if fromCurrency {
                if item.lowercased() == "US$".lowercased() {
                    lblCurrency.text = item
                    baseCurrency = "USD"
                }
                if item.lowercased() == "S$".lowercased() {
                    lblCurrency.text = item
                    baseCurrency = "SGD"
                }
                if item.lowercased() == "€".lowercased() {
                    lblCurrency.text = item
                    baseCurrency = "EUR"
                }
            } else {
                if item.lowercased() == "US$".lowercased() {
                    lblAcCurrency.text = item
                    accountCurrency = "USD"
                }
                if item.lowercased() == "S$".lowercased() {
                    lblAcCurrency.text = item
                    accountCurrency = "SGD"
                }
                if item.lowercased() == "€".lowercased() {
                    lblAcCurrency.text = item
                    accountCurrency = "EUR"
                }
            }
        }
        dropDown.backgroundColor = hexStringToUIColor(hex: "#2C3A4A")
        dropDown.textColor = UIColor.white
        dropDown.selectionBackgroundColor = .clear
        
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            let strPhoneCode = getCountryPhonceCode(countryCode)
            self.imgCountryCode.image = UIImage.init(named: "\(countryCode).png")
            self.txtProfileCountryCode.text = "+\(strPhoneCode)"
            self.countryCodeDesc = countryCode
        }
        
        addPhotoPopUp = Bundle.main.loadNibNamed("AddPhotoPopUp", owner: nil, options: nil)?.first as? AddPhotoPopUp
        addPhotoPopUp.tapToBtnCamera {
            self.loadCameraView()
            self.removeAddPhotoView()
        }
        
        addPhotoPopUp.tapToBtnGallery {
            self.loadPhotoGalleryView()
            self.removeAddPhotoView()
        }
        
        addPhotoPopUp.tapToBtnView {
            self.removeAddPhotoView()
        }
        customDatePickerForBirthDate = CustomDatePickerViewForTextFeild(textField: txtDummyBOD, format: "yyyy-MM-dd", mode: .date)
        customDatePickerForBirthDate.pickerView { (str, date) in
            let arrStr = str.components(separatedBy: "-")
            self.dateOfBirth = str
            self.lblDate.text = arrStr.last
            self.lblMonth.text = arrStr[1]
            self.lblYear.text = arrStr.first
        }
        
        nationalityView = Bundle.main.loadNibNamed("NationalityView", owner: nil, options: nil)?.first as? NationalityView
        nationalityView.tapToBtnSelectItem { obj in
            self.lblNationality.text = obj.country_nationality
        }
        
        successPopUpForCoachProfieView = Bundle.main.loadNibNamed("SuccessPopUpForCoachProfieView", owner: nil, options: nil)?.first as? SuccessPopUpForCoachProfieView
        successPopUpForCoachProfieView.tapToBtnOK {
            self.navigationController?.popViewController(animated: true)
            self.removesuccessPopUpForCoachProfieView()
        }
                
        getNationality()
        getUserProfile()
        
    }
    
    func setData() {
        dropDown.dataSource  = ["US$", "S$", "€"]
        txtProfileUserName.text = userDataObj.username
        txtProfileEmail.text = userDataObj.email
        txtProfilePhone.text = userDataObj.phoneno
        txtProfileCountryCode.text = userDataObj.phonecode
        accountCurrency = userDataObj.account_currency
        baseCurrency = userDataObj.base_currency
        txtProfilePassword.text = DEFAULTS.string(forKey: DEFAULTS_KEY.USER_PASSWORD)
        txtProfileRetypePassword.text = DEFAULTS.string(forKey: DEFAULTS_KEY.USER_PASSWORD)
        if accountCurrency == BaseCurrencyList.USD {
            lblAcCurrency.text = BaseCurrencySymbol.USD
        } else if accountCurrency == BaseCurrencyList.SGD {
            lblAcCurrency.text = BaseCurrencySymbol.SGD
        } else if accountCurrency == BaseCurrencyList.EUR {
            lblAcCurrency.text = BaseCurrencySymbol.EUR
        }
        countryCodeDesc = userDataObj.countrycode
        self.imgCountryCode.image = UIImage.init(named: "\(countryCodeDesc).png")
        self.imgUserProfile.setImageFromURL(imgUrl: userDataObj.user_image, placeholderImage: nil)
    }
    
    
    func setAddPhotoView(){
        addPhotoPopUp.frame.size = self.view.frame.size
        self.view.addSubview(addPhotoPopUp)
    }
    
    func removeAddPhotoView(){
        if addPhotoPopUp != nil{
            addPhotoPopUp.removeFromSuperview()
        }
    }
    
    func setNationalityView(){
        nationalityView.frame.size = self.view.frame.size
        self.view.addSubview(nationalityView)
    }
    
    func removeNationalityView(){
        if nationalityView != nil{
            nationalityView.removeFromSuperview()
        }
    }
    
    func setsuccessPopUpForCoachProfieView(){
        successPopUpForCoachProfieView.frame.size = self.view.frame.size
        self.view.addSubview(successPopUpForCoachProfieView)
    }
    
    func removesuccessPopUpForCoachProfieView(){
        if successPopUpForCoachProfieView != nil{
            successPopUpForCoachProfieView.removeFromSuperview()
        }
    }
    
    // MARK: - Click Event
    @IBAction func clickToBtnSignUpAsCoach(_ sender : UIButton) {
        
        if sender == btnSignUpAsCoach  {
            viwLine1.isHidden = false
            viwSignUpAsCoach.isHidden = false
            viwLine2.isHidden = true
            viwEditProfile.isHidden = true
            
        } else {
            
            viwLine2.isHidden = false
            viwEditProfile.isHidden = false
            viwSignUpAsCoach.isHidden = true
            viwLine1.isHidden = true
        }
    }
    
    @IBAction func clickTobBtnAddPassportPhoto(_ sender: UIButton) {
        selectedButton = btnUploadPasswordIDPhoto
        setAddPhotoView()
    }
    
    @IBAction func clickTobBtnNationality(_ sender: UIButton) {
        setNationalityView()
    }
    
    @IBAction func clickTobBtnTermsAndCondition(_ sender: UIButton) {
        imgTermsCondition.isHighlighted = !imgTermsCondition.isHighlighted
    }
    
    @IBAction func clickTobBtnCurrency(_ sender: UIButton) {
//        setNationalityView()
        dropDown.show()
        dropDown.anchorView = btnCurrency
        fromCurrency = true
        dropDown.width = sender.frame.width
    }
    
    @IBAction func clickTobBtnSubmit(_ sender: UIButton) {
        if txtFirstName.text!.isEmpty {
            Utility.shared.showToast("First name is required.")
        } else if txtFirstName.text!.isEmpty {
            Utility.shared.showToast("Last name is required.")
        }
        else if txtEmail.text!.isEmpty {
            Utility.shared.showToast("Email is required.")
        } else  if !txtEmail.text!.isValidEmail {
            Utility.shared.showToast("Email is not valid.")
        }  else if dateOfBirth.isEmpty {
            Utility.shared.showToast("Date of birth is required.")
        } else if lblNationality.text?.lowercased() == "Nationality".lowercased() {
            Utility.shared.showToast("Nationality is required.")
        } else if txtPasswordIdNUmber.text!.isEmpty {
            Utility.shared.showToast("Passport/Id number is required.")
        } else if photoData == nil {
            Utility.shared.showToast("Upload passport image/ID  is required.")
        } else if txtMonthlySubFee.text!.isEmpty {
            Utility.shared.showToast("Enter your monthly subscription fee")
        } else if imgTermsCondition.isHighlighted == false {
            Utility.shared.showToast("Accept terms and condition")
        } else {
            self.registerAsCoach()
        }
    }
    
    @IBAction func didTapFeeQue(_ sender: UIButton) {
        let vc = PopupViewController.viewcontroller()
        vc.isHide = true
        vc.message = """
                    Monthly Subscription Fee

                    Users will pay a monthly subscription fee to access your classes at a different rate than users who did not subscribe.

                    For every “On Demand” and “Live” Class, you will be able toset a different fee for users who subscribed and users who did not subscribe.

                    The monthly subscription fee can be changed at any time in your profile settings.
                    """
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func didTapCountryCode(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Coach", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CountryPickerVC") as! CountryPickerVC
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func didTapAcCurrency(_ sender: UIButton) {               
        dropDown.show()
        dropDown.anchorView = btnAcCurrency
        fromCurrency = false
        dropDown.width = sender.frame.width
    }
    
    @IBAction func clickTobBtnEditPhoto(_ sender: UIButton) {
        selectedButton = btnEditUserPhoto
        setAddPhotoView()
    }
    
    @IBAction func clickTobBtnSaveUserProfile(_ sender: UIButton) {
        if txtProfileUserName.text!.isEmpty {
            Utility.shared.showToast("User Name is a mandatory field.")
        } else if txtProfilePhone.text!.isEmpty {
            Utility.shared.showToast("Phone number is a mandatory field.")
        } else if txtProfileEmail.text!.isEmpty {
            Utility.shared.showToast("Email is a mandatory field.")
        } else  if !txtProfileEmail.text!.isValidEmail {
            Utility.shared.showToast("Email is not valid.")
        }     else if txtProfilePassword.text!.isEmpty {
            Utility.shared.showToast("Password is a mandatory field.")
        } else {
            editUserProfile()
        }
        
    }


}

// MARK: - UIImagePickerControllerDelegate and Take a Photo or Choose from Gallery Methods
extension EditCoachProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        var editedImage:UIImage!
        editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        if editedImage == nil {
            editedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        
        if editedImage.getSizeIn(.megabyte, recdData: self.photoData ?? Data()) > 5.0 {
            photoData = editedImage.jpegData(compressionQuality: 0.5)
        } else {
            photoData = editedImage.jpegData(compressionQuality: 1.0)
        }
        
        if selectedButton == btnEditUserPhoto {
            self.imgUserProfile.image = editedImage
            
        } else {
            let url = info[UIImagePickerController.InfoKey.referenceURL] as! URL
            self.lblPassportImageName.text = url.lastPathComponent
        }
        
       
        
        picker.dismiss(animated: true, completion: nil)
        self.uploadCoachPhoto()
        
        
    }
    
    
    func loadCameraView() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.navigationBar.tintColor =  #colorLiteral(red: 0.2352941176, green: 0.5098039216, blue: 0.6666666667, alpha: 1)
            imagePickerController.sourceType = .camera
            imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
            imagePickerController.allowsEditing = true
            imagePickerController.delegate = self
            imagePickerController.showsCameraControls = true
            present(imagePickerController, animated: true, completion: nil)
        } else {
            
        }
    }
    
    func loadPhotoGalleryView() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
            imagePickerController.allowsEditing = false
            imagePickerController.delegate = self
            
            
            present(imagePickerController, animated: true, completion: nil)
        } else {
            
        }
    }
}

// MARK: - API call
extension EditCoachProfileViewController {
    func getNationality() {
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .get, urlString: API.NATIONALITY_LIST, parameters: nil, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            if responseModel.success {
                let dataObj = responseObj["data"] as? [Any] ?? [Any]()
                self.arrNationalityData = NationalityData.getData(data: dataObj)
                self.nationalityView.arrNationalityData = self.arrNationalityData
                self.nationalityView.setUpUI()
            }
            
            self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
    func checkEmail() {
        showLoader()
        
        let param = ["email" : txtEmail.text!]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.CHECK_EMAIL, parameters: param, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            if responseModel.success {
                self.registerAsCoach()
            } else{
                Utility.shared.showToast(responseModel.message)
                self.hideLoader()
            }
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
    func registerAsCoach() {
        //showLoader()
        
        let param = ["first_name" : txtFirstName.text!,
                     "last_name" : txtLastName.text!,
                     "email" : txtEmail.text!,
                     "date_of_birth" : dateOfBirth,
                     "nationality" : lblNationality.text!,
                     "passport_number" : txtPasswordIdNUmber.text!,
                     "base_currency" : baseCurrency,
                     "monthly_subscription_fee" : txtMonthlySubFee.text?.description
                     
        ]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.REGISTER_COACH, parameters: param, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            let dataObj = responseObj["data"] as? [String : Any] ?? [String : Any]()
            let email = dataObj["email"] as? String ?? ""
            
            
            if !email.isEmpty {
                let role = dataObj["role"] as? String ?? ""
                AppPrefsManager.sharedInstance.saveUserRole(role: role)
                self.setsuccessPopUpForCoachProfieView()
                
            } else{
                Utility.shared.showToast(responseModel.message)
            }
            
            self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }

    func uploadCoachPhoto() {
        showLoader()
        
        var finalDataParameters = [AnyObject]()

        
        if photoData != nil
        {
            var imageDic = [String:AnyObject]()
            
            imageDic["file_data"] = photoData as AnyObject?
            imageDic["param_name"] = selectedButton == btnEditUserPhoto ? "user_image" as AnyObject? : "user_passport_id_image" as AnyObject?
            imageDic["file_name"] = "image.jpeg" as AnyObject?
            imageDic["mime_type"] = "image" as AnyObject?
            
            finalDataParameters.append(imageDic as AnyObject)
        }
        
        let param = [
//            "user_image": ,
            "type": selectedButton == btnEditUserPhoto ? "user_image" as AnyObject? : "user_passport_id_image" as AnyObject?
        ] as [String : AnyObject]
        
        ApiCallManager.callApiWithUpload(apiURL: API.UPLOAD_USER_IMAGE, method: .post, parameters: param, fileParameters: finalDataParameters, headers: nil, success: { (responseObj, code) in
            let resObj = responseObj as? [String:Any] ?? [String:Any]()
            
            let responseModel = ResponseDataModel(responseObj: resObj)
            if responseModel.success {
                let dataObj = resObj["data"] as? [String:Any] ?? [String:Any]()
                
                self.user_image = dataObj["user_image"] as? String ?? ""
            }
            Utility.shared.showToast(responseModel.message)
            
            
            self.hideLoader()
        }, failure: { error, code in
            self.hideLoader()
            return true
        })
        
    }
        
    func editUserProfile() {
        
        showLoader()
        
        let param = [
            "countrycode": countryCodeDesc,
            "phonecode": txtProfileCountryCode.text!,
            "phoneno" : txtProfilePhone.text!,
            "password" : txtProfilePassword.text!,
            "email" : txtProfileEmail.text!,
            "username": txtProfileUserName.text!,
            "user_image" : user_image,
            "base_currency": baseCurrency ,
            "account_currency": accountCurrency
            
        ] as [String : String]
                
      _ =  ApiCallManager.requestApi(method: .post, urlString: API.EDIT_PROFILE, parameters: param, headers: nil) { responseObj in
            let resObj = responseObj as? [String:Any] ?? [String:Any]()
          print(resObj)
          
          let responseModel = ResponseDataModel(responseObj: resObj)
          
          if responseModel.success {
              
              self.navigationController?.popViewController(animated: true)
          }
          
          Utility.shared.showToast(responseModel.message)
          self.hideLoader()
            
        } failure: { (error) in
            print(error.localizedDescription)
            self.hideLoader()
            return true
        }
    }

    func getUserProfile() {
        showLoader()
        
        _ =  ApiCallManager.requestApi(method: .get, urlString: API.GET_PROFILE, parameters: nil, headers: nil) { responseObj in
            
            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            if responseModel.success {
                let dataObj = responseObj["data"] as? [String:Any] ?? [String:Any]()
                self.userDataObj = UserData(responseObj: dataObj)
                self.setData()
            }
                        
            self.hideLoader()
            
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    

}


extension EditCoachProfileViewController: countryPickDelegate {
    func selectCountry(screenFrom: String, is_Pick: Bool, selectedCountry: Country?) {
        txtProfileCountryCode.text = selectedCountry?.phoneCode
        self.imgCountryCode.image = selectedCountry?.flag
        countryCodeDesc = selectedCountry?.code ?? ""
    }
    
    
}
