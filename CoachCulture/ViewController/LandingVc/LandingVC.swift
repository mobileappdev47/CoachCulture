
import UIKit

class LandingVC: BaseViewController {
    
    static func viewcontroller() -> LandingVC {
        let vc = UIStoryboard(name: "Coach", bundle: nil).instantiateViewController(withIdentifier: "LandingVC") as! LandingVC
        return vc
    }
    
    
    

    //MARK: - OUTLET
    
    @IBOutlet weak var viewLogin: UIView!
    @IBOutlet weak var viewSignUp: UIView!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    
    //MARK: - VARIABLE
    
    //MARK: - VIEW CONTROLLER LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if AppPrefsManager.sharedInstance.isUserLogin() {
            self.goToTabBar()
        }
        
        self.initialSetupUI()
    }
    
   
    //MARK: - OTHER FUNCTION
    
    func initialSetupUI() {
        self.viewLogin.addCornerRadius(10.0)
        self.viewSignUp.addCornerRadius(10.0)
        self.viewSignUp.applyBorder(1.0, borderColor: COLORS.APP_COLOR_LIGHT_GRAY)
        self.btnLogin.setTitle("Login".localized(), for: .normal)
        self.btnSignUp.setTitle("SignUp".localized(), for: .normal)
    }
    
    //MARK: - ACTION
    
    @IBAction func btnLoginClick(_ sender: Any) {
        let nextVc = LoginSignUpVc.instantiate(fromAppStoryboard: .Coach)
        nextVc.isFromLogin = true
        self.navigationController?.pushViewController(nextVc, animated: true)
    }
    
    @IBAction func btnSignUpClick(_ sender: Any) {
        let nextVc = LoginSignUpVc.instantiate(fromAppStoryboard: .Coach)
        nextVc.isFromLogin = false
        self.navigationController?.pushViewController(nextVc, animated: true)
    }
}

//MARK: - EXTENSION
