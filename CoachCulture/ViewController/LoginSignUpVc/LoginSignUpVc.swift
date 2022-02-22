
import UIKit
import SVProgressHUD
import Firebase
import GoogleSignIn
import FBSDKLoginKit


class LoginSignUpVc: BaseViewController {
    
    //MARK: - OUTLET
    
    @IBOutlet weak var viewMainBg: UIView!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var viewLoginMain: UIView!
    @IBOutlet weak var viewSignUpMain: UIView!
    @IBOutlet weak var viewUserNameLogin: UIView!
    @IBOutlet weak var viewPasswordLogin: UIView!
    @IBOutlet weak var imgRememberMe: UIImageView!
    @IBOutlet weak var lblRememberMe: UILabel!
    @IBOutlet weak var btnForgotPassword: UIButton!
    @IBOutlet weak var viewUserNameSignUp: UIView!
    @IBOutlet weak var viewCountryCode: UIView!
    @IBOutlet weak var viewPhone: UIView!
    @IBOutlet weak var viewPasswordSignUp: UIView!
    @IBOutlet weak var viewRetypePasswordSignUp: UIView!
    @IBOutlet weak var imgSubmitArrowLogin: UIImageView!
    @IBOutlet weak var imgSubmitArrowSignUp: UIImageView!
    @IBOutlet weak var viewInstagram: UIView!
    @IBOutlet weak var viewFB: UIView!
    @IBOutlet weak var imgAcceptTerms: UIImageView!
    @IBOutlet weak var lblTermsAndConditions: UILabel!
    
    @IBOutlet weak var btnLoginTapped: UIButton!
    @IBOutlet weak var btnSignupTapped: UIButton!
    
    @IBOutlet weak var viewEmailSignup: UIView!
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtRePassword: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtCountryCode: UITextField!
    @IBOutlet weak var imgCountryCode: UIImageView!
    
    @IBOutlet weak var txtUsernameLogin: UITextField!
    @IBOutlet weak var txtPasswordLogin: UITextField!
    
    //MARK: - VARIABLE
    
    var isRememberMe = false
    var isAcceptTermsAndCondition = false
    var isFromLogin = false
    let apimanager = ApiManager()
    var countryCodeDesc = ""
    var base_currency = ""
    
    let txtPlaceholders = ["Username", "Password", "Username", "Email", "", "Phone", "Password", "Retype Password"]
    var loginParams = [String:Any]()

    //MARK: - VIEW CONTROLLER LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            let strPhoneCode = getCountryPhonceCode(countryCode)
            self.imgCountryCode.image = UIImage.init(named: "\(countryCode).png")
            self.txtCountryCode.text = "+\(strPhoneCode)"
            self.countryCodeDesc = countryCode
        }
        
        //comment code - comment the static cred
        txtUsernameLogin.text = "devuser"
        txtPasswordLogin.text = "Test@123"
    }
    
    fileprivate func setupViews() {
        [txtUsernameLogin,
         txtPasswordLogin,
         txtUsername,
         txtEmail,
         txtCountryCode,
         txtPhone,
         txtPassword,
         txtRePassword
        ].enumerated().forEach { index, txt in
            let place = txtPlaceholders[index]
            txt?.attributedPlaceholder = NSAttributedString(string: place, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor: COLORS.TEXT_COLOR])
            txt?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            txt?.textColor = COLORS.TEXT_COLOR
            txt?.tintColor = COLORS.TEXT_COLOR
            
            txt?.layer.cornerRadius = 10
            txt?.clipsToBounds = true
        }
        btnLogin.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        btnSignUp.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.initialSetupUI()
    }
    
    //MARK: - OTHER FUNCTION
    
    func initialSetupUI() {
        self.manageLoginSignUpView(isLogin: isFromLogin)
        
        self.viewUserNameLogin.addCornerRadius(10.0)
        self.viewPasswordLogin.addCornerRadius(10.0)
        self.viewUserNameSignUp.addCornerRadius(10.0)
        self.viewCountryCode.addCornerRadius(10.0)
        self.viewPhone.addCornerRadius(10.0)
        self.viewPasswordSignUp.addCornerRadius(10.0)
        self.viewRetypePasswordSignUp.addCornerRadius(10.0)
        self.viewLoginMain.addCornerRadius(10.0)
        self.viewSignUpMain.addCornerRadius(10.0)
        self.viewMainBg.addCornerRadius(10.0)
        self.viewFB.addCornerRadius(self.viewFB.frame.height / 2)
        self.viewInstagram.addCornerRadius(self.viewInstagram.frame.height / 2)
        viewEmailSignup.addCornerRadius(10.0)
        
        self.btnLogin.setTitle("Login".localized(), for: .normal)
        self.btnSignUp.setTitle("SignUp".localized(), for: .normal)
        
        let underlineAttriString = NSMutableAttributedString(string: lblTermsAndConditions.text ?? "")
        let range1 = ((lblTermsAndConditions.text ?? "") as NSString).range(of: "Terms & Conditions".localized())
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
        
        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: range1)
        
        lblTermsAndConditions.attributedText = underlineAttriString
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        btnForgotPassword.addTarget(self, action: #selector(didTapForgot(_:)), for: .touchUpInside)
        
        btnLoginTapped.addTarget(self, action: #selector(btnLoginTappedClick(_:)), for: .touchUpInside)
        btnSignupTapped.addTarget(self, action: #selector(btnSignupTappedClick(_:)), for: .touchUpInside)
    }
    
    @objc func didTapForgot(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ForgotPassViewController") as! ForgotPassViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func changeRememberMeStatus(flag: Bool) {
        imgRememberMe.image = flag ? UIImage(named: "ic_checked") : UIImage(named: "ic_unchecked")
    }
    
    func changeAcceptTermsAndConditionStatus(flag: Bool) {
        imgAcceptTerms.image = flag ? UIImage(named: "ic_checked") : UIImage(named: "ic_unchecked")
    }
    
    func manageLoginSignUpView(isLogin: Bool = false) {
        if isLogin {
            self.imgSubmitArrowLogin.isHidden = false
            self.imgSubmitArrowSignUp.isHidden = true
            self.viewLoginMain.isHidden = false
            self.viewSignUpMain.isHidden = true
            btnLoginTapped.isHidden = false
            btnSignupTapped.isHidden = true
        } else {
            self.imgSubmitArrowLogin.isHidden = true
            self.imgSubmitArrowSignUp.isHidden = false
            self.viewLoginMain.isHidden = true
            self.viewSignUpMain.isHidden = false
            btnLoginTapped.isHidden = true
            btnSignupTapped.isHidden = false
        }
    }
    
    //MARK: - ACTION
    
    @IBAction func btnRememberMeClick(_ sender: Any) {
        isRememberMe = !isRememberMe
        self.changeRememberMeStatus(flag: isRememberMe)
    }
    
    @IBAction func btnAcceptTermsAndConditionClick(_ sender: Any) {
        isAcceptTermsAndCondition = !isAcceptTermsAndCondition
        self.changeAcceptTermsAndConditionStatus(flag: isAcceptTermsAndCondition)
    }
    
    @IBAction func btnLoginClick(_ sender: Any) {
        self.manageLoginSignUpView(isLogin: true)
    }
    
    @IBAction func btnSignUpClick(_ sender: Any) {
        self.manageLoginSignUpView(isLogin: false)
    }
    
    @IBAction func didTapCountryCode(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CountryPickerVC") as! CountryPickerVC
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func btnLoginTappedClick(_ sender: UIButton) {
        if validationLogin() {
            loginParams = [
                "username": txtUsernameLogin.text!,
                "password": txtPasswordLogin.text!,
                "login_type": 0
            ]
            loginAPI()
        }
    }
    
    @objc func btnSignupTappedClick(_ sender: UIButton) {
        if validationSignup() {
            //            let vc = OTPViewController.viewcontroller()
            //            vc.phoneNo = txtPhone.text!
            //            vc.verifiedCallback = { [weak self] in
            //                guard self != nil else {return}
            print("SingupAPI")
            self.signupAPI()
            //            }
            //            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func clickToBtnGoogleSignIn( _ sender : UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            if let error = error {
                Utility.shared.showToast(error.localizedDescription)
                return
            }
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            //let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            loginParams = [
                Params.Login.google_id: idToken,
                Params.Login.login_type: LoginType.Google,
            ]
            loginAPI()
        }
    }
    
    @IBAction func clickToBtnFacebookLogin ( _ sender: UIButton) {
        let loginManager = LoginManager()
        if let _ = AccessToken.current {
            loginManager.logOut()
        } else {
            loginManager.logIn(permissions: [], from: self) { [weak self] (result, error) in
                guard error == nil else {
                    Utility.shared.showToast(error?.localizedDescription ?? "Something went wrong!")
                    return
                }
                guard let result = result, !result.isCancelled else {
                    return
                }
                Profile.loadCurrentProfile { (profile, error) in
                    self?.loginParams = [
                        Params.Login.facebook_id: result.token ?? "",
                        Params.Login.login_type: LoginType.Facebook,
                    ]
                    self?.loginAPI()
                    //print(Profile.current?.name)
                }
            }
        }
    }
    
    func validationSignup() -> Bool {
        
        if txtUsername.text!.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            Utility.shared.showToast("Username is mandatory field")
            return false
        } else if txtUsername.text?.contains(" ") ?? false {
            Utility.shared.showToast("Space not allowed")
            return false
        }
        else  if txtEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            Utility.shared.showToast("Email is mandatory field")
            return false
        } else if !(txtEmail.text!.isValidEmail) {
            Utility.shared.showToast("Wrong formate for email address")
            return false
        }
        else  if txtPhone.text!.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            Utility.shared.showToast("Mobile number is mandatory field")
            return false
        }  else  if txtPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            Utility.shared.showToast("Password is mandatory field")
            return false
        } else  if txtPassword.text?.isValidPassword ?? false {
            Utility.shared.showToast("Password must be contain uppercase, lowercase, digit, sign letter")
            return false
        } else  if txtRePassword.text!.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            Utility.shared.showToast("Re-Type password is mandatory field")
            return false
        } else if txtPassword.text! != txtRePassword.text! {
            
            Utility.shared.showToast("Password and ReEnter password not matched")
            return false
        } else if isAcceptTermsAndCondition == false {
            Utility.shared.showToast("Please accept terms and condition")
            return false
        } else {
            return true
        }
    }
    
    func validationLogin() -> Bool {
        if txtUsernameLogin.text!.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            Utility.shared.showToast("Email is mandatory field")
            return false
        } else if txtUsernameLogin.text?.contains(" ") ?? false {
            Utility.shared.showToast("Space not allowed")
            return false
        } else if txtPasswordLogin.text!.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            Utility.shared.showToast("Password is mandatory field")
            return false
        } else if txtPasswordLogin.text?.isValidPassword ?? false {
            Utility.shared.showToast("Password must be contain uppercase, lowercase, digit, sign letter")
            return false
        } else {
            return true
        }
    }
    
}

extension LoginSignUpVc: countryPickDelegate {
    func selectCountry(screenFrom: String, is_Pick: Bool, selectedCountry: Country?) {
        txtCountryCode.text = selectedCountry?.phoneCode
        self.imgCountryCode.image = selectedCountry?.flag
        countryCodeDesc = selectedCountry?.code ?? ""
        
        let continentObj = Utility.shared.readLocalFile(forName: "continent")
    
        let filteredCountry = continentObj?.filter({ (dict) -> Bool in
            if selectedCountry?.code == "AX" {
                return dict.key == "FI"
            } else {
                return dict.key == selectedCountry?.code
            }
        })
    
        if filteredCountry?.count ?? 0 > 0 {
            switch selectedCountry?.currencyCode {
            case BaseCurrencyList.SGD:
                base_currency = BaseCurrencyList.SGD
            case BaseCurrencyList.EUR:
                base_currency = BaseCurrencyList.EUR
            default:
                base_currency = BaseCurrencyList.USD
            }
        }
    }
}

//MARK: - EXTENSION API CALL
extension LoginSignUpVc {
    
    func signupAPI() {
        
        let param = [
            "username": txtUsername.text!,
            "password": txtPassword.text!,
            "countrycode":countryCodeDesc,
            "base_currency":base_currency,
            "phonecode":txtCountryCode.text!,
            "phoneno":txtPhone.text!,
            "email":txtEmail.text!
        ]
        
        apimanager.callMultiPartDataWebServiceNew(type: SignupUserModel.self, image: nil, to: API.REGISTER_USER, params: param) { userModel, statusCode in
            print("statusCode == == ",statusCode)
            print(userModel)
            if statusCode != 201 && statusCode != 200 {
                self.showAlert(withTitle: "Error!", message: userModel?.message ?? "")
            } else {
                if let userr = userModel {
                    self.handleSignup(model: userr)
                }
            }
        } failure: { error, statusCode in
            print(error.localizedDescription)
        }
    }
    
    func handleSignup(model: SignupUserModel) {
        let vc = PopupViewController.viewcontroller()
        vc.message = "Please check email or phone to verification code"
        vc.dismissHandler = { [weak self] in
            guard let self = self else {return}
            let vc = OTPViewController.viewcontroller()
            vc.countryCode = self.countryCodeDesc
            vc.phoneCode = self.txtCountryCode.text!
            vc.phoneNo = self.txtPhone.text!
            vc.username = self.txtUsername.text!
            vc.password = self.txtPassword.text!
            vc.verifyotp = "\(model.user?.verificationCode ?? 0)"
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func loginAPI() {
        showLoader()
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.LOGIN, parameters: loginParams, headers: nil) { responseObj in
            let resObj = responseObj as? [String:Any] ?? [String:Any]()
            print(resObj)
            
            let responseModel = ResponseDataModel(responseObj: resObj)
            
            if responseModel.success {
                
                let dataObj = resObj["data"] as? [String:Any] ?? [String:Any]()
                AppPrefsManager.sharedInstance.saveUserAccessToken(token: dataObj["access_token"] as? String ?? "")
                AppPrefsManager.sharedInstance.setIsUserLogin(isUserLogin: true)
                
                let userObj = dataObj["user"] as? [String:Any] ?? [String:Any]()
                AppPrefsManager.sharedInstance.saveUserData(userData: userObj)
                let role = userObj["role"] as? String ?? ""
                AppPrefsManager.sharedInstance.saveUserRole(role: role)
                self.goToTabBar()
            }
            Utility.shared.showToast(responseModel.message)
            self.hideLoader()
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
    
}
