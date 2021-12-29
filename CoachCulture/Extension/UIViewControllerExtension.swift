
import UIKit

extension UIViewController {    
    class var storyboardID: String {
        return "\(self)"
    }
    
    static func instantiate(fromAppStoryboard appStoryboard: AppStoryboard) -> Self {
        return appStoryboard.viewController(viewControllerClass: self)
    }
    
    func pushVC(To nextVC: UIViewController, animated: Bool) {
        self.navigationController?.pushViewController(nextVC, animated: animated)
    }
    
    func popVC(animated: Bool) {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: animated)
        }
    }
    
    func showAlert(withTitle title: String?, message: String?) {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
      alert.addAction(action)
      present(alert, animated: true, completion: nil)
    }
    
    func showToast(message : String, seconds: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = COLORS.APP_COLOR_MEDIUM_GRAY
        alert.view.alpha = 0.5
        alert.view.layer.cornerRadius = 15
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
    
    @IBAction func didTapBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    var window: UIWindow? {
        if #available(iOS 13, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let delegate = windowScene.delegate as? SceneDelegate, let window = delegate.window else { return nil }
                   return window
        }
        
        guard let delegate = UIApplication.shared.delegate as? AppDelegate, let window = delegate.window else { return nil }
        return window
    }
}
