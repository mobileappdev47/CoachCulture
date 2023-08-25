
import UIKit
import SVProgressHUD
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import PhoneNumberKit
import SafariServices
import AuthenticationServices

class LoginSignUpVc: BaseViewController, ASAuthorizationControllerDelegate {
    
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
    @IBOutlet weak var btnTermsAndCondition: UIButton!
    
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
    
    @IBOutlet weak var imgErrUsername: UIImageView!
    @IBOutlet weak var imgErrPhone: UIImageView!
    @IBOutlet weak var imgErrEmail: UIImageView!
    @IBOutlet weak var imgErrPwd: UIImageView!
    @IBOutlet weak var imgErrRePwd: UIImageView!
    
    @IBOutlet weak var imgErrUserNameLogin: UIImageView!
    @IBOutlet weak var imgErrPasswordLogin: UIImageView!
    
    @IBOutlet weak var viewAppleLogin: UIView!

    //MARK: - VARIABLE
    
    var isRememberMe = false
    var isAcceptTermsAndCondition = false
    var isFromLogin = false
    let apimanager = ApiManager()
    var countryCodeDesc = ""
    var base_currency = "USD"
    var LoginType = LoginTypeConst(rawValue: 0)
    let txtPlaceholders = ["Username", "Password", "Username", "Email", "", "Phone", "Password", "Retype Password"]
    var loginParams = [String:Any]()
    var username = ""
    var email = ""
    var socialID = ""
    
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
        self.setUpSignInAppleButton()
    }
    
    override func viewDidLayoutSubviews() {
//        viewAppleLogin.addSubview(authorizationButton)
        self.setUpSignInAppleButton()
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
            txt?.delegate = self
            //txt?.layer.cornerRadius = 10
            txt?.clipsToBounds = true
        }
        btnLogin.titleLabel?.font = UIFont(name: "SFProText-Semibold", size: 18.0) ?? UIFont.systemFont(ofSize: 18, weight: .semibold)
        btnSignUp.titleLabel?.font = UIFont(name: "SFProText-Semibold", size: 18.0) ?? UIFont.systemFont(ofSize: 18, weight: .semibold)
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
        
        var is_rememberMe = false
        
        if let isRememberMe = DEFAULTS.value(forKey: DEFAULTS_KEY.IS_REMEMBER_ME) as? Bool, isRememberMe {
            txtUsernameLogin.text = DEFAULTS.string(forKey: DEFAULTS_KEY.USERNAME)
            txtPasswordLogin.text = DEFAULTS.string(forKey: DEFAULTS_KEY.USER_PASSWORD)
            is_rememberMe = isRememberMe
        }
        self.isRememberMe = is_rememberMe
        self.changeRememberMeStatus(flag: isRememberMe)
    }
    
    @objc func didTapForgot(_ sender: UIButton) {
        removeAllErrLogin()
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
            errorForBlankText(true, true, true, true, true)
            removeAllErrSignUp()
        } else {
            removeAllErrLogin()
            imgErrPasswordLogin.isHidden = true
            imgErrUserNameLogin.isHidden = true
            self.imgSubmitArrowLogin.isHidden = true
            self.imgSubmitArrowSignUp.isHidden = false
            self.viewLoginMain.isHidden = true
            self.viewSignUpMain.isHidden = false
            btnLoginTapped.isHidden = true
            btnSignupTapped.isHidden = false
        }
    }
    
    func errorForBlankText(_ username: Bool,_ phone: Bool,_ email: Bool,_ password: Bool,_ rePassword: Bool) {
        imgErrUsername.isHidden = username
        imgErrPhone.isHidden = phone
        imgErrEmail.isHidden = email
        imgErrPwd.isHidden = password
        imgErrRePwd.isHidden = rePassword
    }
    
    func removeAllErrLogin() {
        txtPasswordLogin.setError()
        txtUsernameLogin.setError()
    }
    
    func removeAllErrSignUp() {
        txtUsername.setError()
        txtPassword.setError()
        txtRePassword.setError()
        txtEmail.setError()
        txtPhone.setError()
    }
    
    //MARK: - ACTION
    
    @IBAction func btnRememberMeClick(_ sender: Any) {
        isRememberMe = !isRememberMe
        DEFAULTS.setValue(isRememberMe, forKey: DEFAULTS_KEY.IS_REMEMBER_ME)
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
    
    @IBAction func btnTermsAndConditionClicked(_ sender: UIButton) {        
        guard let url = URL(string: "https://generator.lorem-ipsum.info/terms-and-conditions") else {
            return
        }
        let vc = SFSafariViewController(url: url)
        self.present(vc, animated: true, completion: nil)
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
                "device_token": "cvcxvxv22v1xcvv2vaavavfdv2a2vdsv", //DEFAULTS.value(forKey: DEFAULTS_KEY.FCM_TOKEN) as? String ?? ""
                "login_type": 0
            ]
            if Reachability.isConnectedToNetwork(){
                loginAPI()
            }
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

        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] user, error in
//
            if let error = error {
                // ...
                return
            }

            guard let user =  user?.user, let idToken = user.idToken?.tokenString else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

//            guard let user = GIDSignIn.sharedInstance.currentUser, let authentication = user.authentication, let idToken = authentication.idToken else {
//                return
//            }
            //let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)

            self.socialID = idToken
            loginParams = [
                Params.Login.google_id: idToken,
                Params.Login.login_type: LoginTypeConst.Google.rawValue,
                Params.Login.device_token: DEFAULTS.value(forKey: DEFAULTS_KEY.FCM_TOKEN) as? String ?? ""
            ]
            if let email = user.profile?.email {
                self.email = email
                self.txtEmail.text = self.email
            }
            if let username = user.profile?.name {
                self.username = username
                self.txtUsername.text = self.username
            }

            viewPasswordSignUp.isHidden = true
            viewRetypePasswordSignUp.isHidden = true

            LoginType = LoginTypeConst.Google
            loginAPI()
            
//            signupAPI()
        }
    }

    @IBAction func clickToBtnFacebookLogin ( _ sender: UIButton) {
        let loginManager = LoginManager()
        if let _ = AccessToken.current {
            loginManager.logOut()
        } else {
            loginManager.logIn(permissions: ["public_profile", "email"], from: self) { [weak self] results, error in
                guard error == nil else {
                    Utility.shared.showToast(error?.localizedDescription ?? "Something went wrong!")
                    return
                }
                guard let result = results, !result.isCancelled else {
                    return
                }
                Profile.loadCurrentProfile { [self] (profile, error) in
                    self?.socialID = (results?.token!.tokenString)!
                    self?.loginParams = [
                        Params.Login.facebook_id: results?.token?.tokenString ?? "",
                        Params.Login.login_type: LoginTypeConst.Facebook.rawValue,
                        Params.Login.device_token: DEFAULTS.value(forKey: DEFAULTS_KEY.FCM_TOKEN) as? String ?? ""
                    ]
                    
                    if let username = profile?.name {
                        self?.username = username
                        self?.txtUsername.text = self?.username
                    }

                    self?.viewPasswordSignUp.isHidden = true
                    self?.viewRetypePasswordSignUp.isHidden = true
                    
                    self?.LoginType = LoginTypeConst.Facebook
                    self?.loginAPI()
//                    self?.signupAPI()
                    //print(Profile.current?.name)
                }
            }
        }
    }
    
    func validationSignup() -> Bool {
        
        print(txtPassword.text ?? "")
        var phoneNo = ""
        var dialCode = ""
        
        let phoneNumberKit = PhoneNumberKit()
        do {
            let phoneNumber = try phoneNumberKit.parse("\(txtCountryCode.text ?? "")\(txtPhone.text ?? "")")
            phoneNo = "\(phoneNumber.nationalNumber)"
            dialCode = phoneNumber.regionID ?? ""
        } catch {
            print("Generic parser error")
        }
        
        if txtUsername.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            txtUsername.setError("Username is mandatory field", show: true)
            errorForBlankText(false, true, true, true, true)
            return false
        } else if txtUsername.text?.contains(" ") ?? false {
            txtUsername.setError("Space not allowed", show: true)
            errorForBlankText(false, true, true, true, true)
            return false
        }
//        else  if txtPhone.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
//            txtPhone.setError("Please enter a valid phone", show: true)
//            errorForBlankText(true, false, true, true, true)
//            return false
//        }
//        else if !(txtPhone.text?.isEmpty ?? false) && !Utility.shared.checkPhoneNumberValidation(number: phoneNo, countryCodeStr: dialCode) {
//            txtPhone.setError("Please enter a valid phone", show: true)
//            errorForBlankText(true, false, true, true, true)
//            return false
//        }
        else if txtEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            txtEmail.setError("Email is mandatory field", show: true)
            errorForBlankText(true, true, false, true, true)
            return false
        }
        else if !(txtEmail.text!.isValidEmail) {
            txtEmail.setError("Wrong formate for email address", show: true)
            errorForBlankText(true, true, false, true, true)
            return false
        } else  if txtPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 && LoginType == LoginTypeConst.Standard {
            txtPassword.setError("Password is mandatory field", show: true)
            errorForBlankText(true, true, true, false, true)
            return false
        } else  if !(txtPassword.text?.isValidPassword() ?? false) && LoginType == LoginTypeConst.Standard  {
            txtPassword.setError("Password must be contain uppercase, lowercase, digit, sign letter", show: true)
            errorForBlankText(true, true, true, false, true)
            return false
        } else  if txtRePassword.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 && LoginType == LoginTypeConst.Standard {
            txtRePassword.setError("Re-Type password is mandatory field", show: true)
            errorForBlankText(true, true, true, true, false)
            return false
        } else if txtPassword.text! != txtRePassword.text! && LoginType == LoginTypeConst.Standard {
            txtRePassword.setError("Password and ReEnter password not matched", show: true)
            errorForBlankText(true, true, true, true, false)
            return false
        } else if isAcceptTermsAndCondition == false {
            Utility.shared.showToast("Please accept terms and condition")
            return false
        } else {
            errorForBlankText(true, true, true, true, true)
            removeAllErrSignUp()
            txtRePassword.setError("", show: false)
            txtEmail.setError("", show: false)
            txtPhone.setError("", show: false)
            return true
        }
    }
    
    func validationLogin() -> Bool {
        if txtUsernameLogin.text!.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            txtUsernameLogin.setError("Username is mandatory field", show: true)
            imgErrUserNameLogin.isHidden = false
            return false
        } else if txtUsernameLogin.text?.contains(" ") ?? false {
            txtUsernameLogin.setError("Space not allowed", show: true)
            imgErrUserNameLogin.isHidden = false
            return false
        } else if txtPasswordLogin.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            txtPasswordLogin.setError("Password is mandatory field", show: true)
            imgErrPasswordLogin.isHidden = false
            imgErrUserNameLogin.isHidden = true
            return false
        } else {
            removeAllErrLogin()
            imgErrPasswordLogin.isHidden = true
            imgErrUserNameLogin.isHidden = true
            return true
        }
    }
    


//MARK:- Login with apple id

    func setUpSignInAppleButton() {
        
        if #available(iOS 13.0, *) {
            let customAppleLoginBtn = UIButton()
            customAppleLoginBtn.layer.cornerRadius = 8.0
            customAppleLoginBtn.layer.borderWidth = 2.0
            customAppleLoginBtn.backgroundColor = UIColor.black
            customAppleLoginBtn.layer.borderColor = UIColor.black.cgColor
            customAppleLoginBtn.setTitle("Sign in with Apple", for: .normal)
            customAppleLoginBtn.setTitleColor(UIColor.white, for: .normal)
            customAppleLoginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            customAppleLoginBtn.setImage(UIImage(named: "appleLogo"), for: .normal)
            customAppleLoginBtn.imageEdgeInsets = UIEdgeInsets.init(top: 2, left: 0, bottom: 5, right: 12)
            customAppleLoginBtn.addTarget(self, action: #selector(handleAppleIdRequest), for: .touchUpInside)

                //Add button on some view or stack
            self.viewAppleLogin.addSubview(customAppleLoginBtn)
            customAppleLoginBtn.center = self.viewAppleLogin.center
            customAppleLoginBtn.frame = CGRect(x: 0, y: 0, width: self.viewAppleLogin.frame.width, height: self.viewAppleLogin.frame.height)
        }
    }
    
    @objc func handleAppleIdRequest() {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        } else {
            // Fallback on earlier versions
        }
     
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
    let userIdentifier = appleIDCredential.user
        let fullName = appleIDCredential.fullName
    let email = appleIDCredential.email
    let userFirstName = appleIDCredential.fullName?.givenName
    let userLastName = appleIDCredential.fullName?.familyName
        print("User id is \(userIdentifier) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: email))")
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: userIdentifier) {  (credentialState, error) in
             switch credentialState {
                case .authorized:
                    // The Apple ID credential is valid.
                    self.loginParams = [
                        Params.Login.apple_id: userIdentifier,
                        Params.Login.login_type: LoginTypeConst.Apple.rawValue,
                        Params.Login.device_token: DEFAULTS.value(forKey: DEFAULTS_KEY.FCM_TOKEN) as? String ?? "",
                        "email":email ?? "",
                        "first_name" : userFirstName ?? "",
                        "last_name" : userLastName ?? ""
                        //"username"
                    ]
                    self.socialID = userIdentifier
                    self.loginAPI()
                    self.LoginType = LoginTypeConst.Apple
                    break
                case .revoked:
                    // The Apple ID credential is revoked.
                    break
                case .notFound:
                    // No credential was found, so show the sign-in UI.
                    break
                default:
                    break
             }
        }
    }
        
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
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
//            case BaseCurrencyList.INR:
//                base_currency = BaseCurrencyList.INR
            default:
                base_currency = BaseCurrencyList.USD
            }
        }
    }
}

//MARK: - EXTENSION API CALL
extension LoginSignUpVc {
    
    func signupAPI() {
        
        var param = [String:Any]()
        
        if LoginType == LoginTypeConst.Google {
            param["signup_type"] = LoginTypeConst.Google.rawValue
            param[Params.Login.google_id] = self.socialID
            
        } else if LoginType == LoginTypeConst.Facebook {
            param["signup_type"] = LoginTypeConst.Facebook.rawValue
            param[Params.Login.facebook_id] = self.socialID
        } else if LoginType == LoginTypeConst.Apple {
            param["signup_type"] = LoginTypeConst.Apple.rawValue
            param[Params.Login.apple_id] = self.socialID
            param["password"] = txtPassword.text!
        } else {
            param["signup_type"] = LoginTypeConst.Standard.rawValue
            param["password"] = txtPassword.text!
        }
        
        param["username"] = txtUsername.text!
        param["countrycode"] = countryCodeDesc
        param["base_currency"] = base_currency
        param["phonecode"] = txtCountryCode.text!
        param["phoneno"]  = txtPhone.text!
        param["email"] = txtEmail.text!
        param["device_token"] = "cvcxvxv22v1xcvv2vaavavfdv2a2vdsv" // DEFAULTS.value(forKey: DEFAULTS_KEY.FCM_TOKEN) as? String ?? "" // "cvcxvxv22v1xcvv2vaavavfdv2a2vdsv"
        
        apimanager.callMultiPartDataWebServiceNew(type: SignupUserModel.self, image: nil, to: API.REGISTER_USER, params: param) { userModel, statusCode in
            print("statusCode == == ",statusCode)
            print(userModel)
            
            if statusCode != 201 && statusCode != 200 {
                self.showAlert(withTitle: "Error!", message: userModel?.message ?? "")
            } else {
                if let userr = userModel {
                    //                    guard let self = self else {return}
                    let vc = OTPViewController.viewcontroller()
                    vc.LoginType = self.LoginType
                    vc.countryCode = self.countryCodeDesc
                    vc.phoneCode = self.txtCountryCode.text!
                    vc.phoneNo = self.txtPhone.text!
                    vc.username = self.txtUsername.text!
                    vc.password = self.txtPassword.text!
                    DEFAULTS.setValue(self.txtPassword.text, forKey: DEFAULTS_KEY.USER_PASSWORD)
                    AppPrefsManager.sharedInstance.saveUserRole(role: "user")
                    vc.otp = "\(userr.user?.verificationCode ?? 1234)"
                    vc.email = self.txtEmail.text!
                    if userr.user?.phoneno == "" {
                        vc.emaiOrPhone = self.txtEmail.text!
                    } else {
                        vc.phoneNo = self.txtPhone.text!
                    }
                    DispatchQueue.main.async {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        } failure: { error, statusCode in
            if let email = error?.errors?.email {
//                Utility.shared.showToast(email.first ?? "")
                self.showPopUpForAlready()
            }
            else if let phone = error?.errors?.phoneno {
//                Utility.shared.showToast(phone.first ?? "")
                self.showPopUpForAlready()
            }
            else if let username = error?.errors?.username {
//                Utility.shared.showToast(username.first ?? "")
                self.showPopUpForAlready()
            }
        }
    }
    
    func showPopUpForAlready() {
        let vc = PopupViewController.viewcontroller()
        vc.isHide = true
        vc.titleTxt = "Already Signed Up"
        vc.message = "Looks like you already have an account at CoachCulture.Having multiple accounts is currently not supported."
        self.present(vc, animated: true, completion: nil)
    }
    
    func handleSignup(model: SignupUserModel) {
        let vc = PopupViewController.viewcontroller()
        vc.message = "Please check email or phone to verification code"
        vc.dismissHandler = { [weak self] in
            
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func loginAPI() {
        showLoader()
        _ =  ApiCallManager.requestApi(method: .post, urlString: API.LOGIN, parameters: loginParams, headers: nil) { [self] responseObj in
            let resObj = responseObj as? [String:Any] ?? [String:Any]()
            print(resObj)
            
            let responseModel = ResponseDataModel(responseObj: resObj)
            
            if responseModel.success {
                let dataObj = resObj["data"] as? [String:Any] ?? [String:Any]()
                AppPrefsManager.sharedInstance.saveUserAccessToken(token: dataObj["access_token"] as? String ?? "")
                AppPrefsManager.sharedInstance.setIsUserLogin(isUserLogin: true)
                if self.isRememberMe {
                    DEFAULTS.setValue(self.txtUsernameLogin.text!, forKey: DEFAULTS_KEY.USERNAME)
                    DEFAULTS.setValue(self.txtPasswordLogin.text, forKey: DEFAULTS_KEY.USER_PASSWORD)
                }
                let userObj = dataObj["user"] as? [String:Any] ?? [String:Any]()
                AppPrefsManager.sharedInstance.saveUserData(userData: userObj)
                let stripeCustomeId = userObj["stripe_customer_id"] as? String ?? ""
                let loginType = userObj["login_type"] as? String ?? ""
                DEFAULTS.setValue(stripeCustomeId, forKey: DEFAULTS_KEY.STRIPE_CUSTOMER_ID)
                DEFAULTS.setValue(loginType, forKey: DEFAULTS_KEY.LOGIN_TYPE)
                
                
                if self.LoginType == LoginTypeConst.Google || self.LoginType == LoginTypeConst.Facebook || self.LoginType == LoginTypeConst.Apple {
                    if (userObj["phoneno"] as? String != nil && userObj["phoneno"] as? String != "") && (userObj["email"] as? String != nil && userObj["email"] as? String != "") {
                        let role = userObj["role"] as? String ?? ""
                        AppPrefsManager.sharedInstance.saveUserRole(role: role)
                        self.goToTabBar()
                    } else {
//                        self.signupAPI()
                        self.manageLoginSignUpView(isLogin: false)
                        
                        if let email = dataObj["email"] as? String{
                            self.email = email
                            self.txtEmail.text = self.email
                        }
                        if let phone = dataObj["phoneno"] as? String {
                            self.username = phone
                            self.txtPhone.text = self.username
                        }
                        
                        viewPasswordSignUp.isHidden = true
                        viewRetypePasswordSignUp.isHidden = true
                    }
                } else {
                    let role = userObj["role"] as? String ?? ""
                    AppPrefsManager.sharedInstance.saveUserRole(role: role)
                    self.goToTabBar()
                }
                
            } else {
                if self.LoginType == LoginTypeConst.Google || self.LoginType == LoginTypeConst.Facebook || self.LoginType == LoginTypeConst.Apple {
                    self.manageLoginSignUpView(isLogin: false)
                    self.viewPasswordSignUp.isHidden = true
                    self.viewRetypePasswordSignUp.isHidden = true
                    self.txtPassword.text = "Test@123"
                    self.txtRePassword.text = "Test@123"
                    self.txtPassword.isUserInteractionEnabled = false
                    self.txtRePassword.isUserInteractionEnabled = false
                    self.txtEmail.text = self.email
                    self.txtUsername.text = self.username
                } else {
                    Utility.shared.showToast(responseModel.message)
                }
            }
            self.hideLoader()
        } failure: { (error) in
            self.hideLoader()
            return true
        }
    }
}
    
extension LoginSignUpVc: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        removeAllErrLogin()
        removeAllErrSignUp()
        errorForBlankText(true, true, true, true, true)
        imgErrPasswordLogin.isHidden = true
        imgErrUserNameLogin.isHidden = true
        if textField == txtPassword {
            let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            txtPassword.text = ""
            txtPassword.text = newText
            return false
        } else if textField == txtRePassword {
            let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            txtRePassword.text = ""
            txtRePassword.text = newText
            return false
        } else if textField == txtPasswordLogin {
            let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            txtPasswordLogin.text = ""
            txtPasswordLogin.text = newText
            return false
        }
        return true
    }
}
