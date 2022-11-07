//
//  CheckBalanceViewController.swift
//  CoachCulture
//
//  Created by mac on 13/08/1944 Saka.
//

import UIKit
import PassKit

class CheckBalanceViewController: UIViewController {

    @IBOutlet weak var clickBtnBack: UIButton!
    @IBOutlet weak var totalPointLbl: UILabel!
    @IBOutlet weak var addPointsBtn: UIButton!
    
    let userDefaults = UserDefaults.standard
    var countingPoints = 0
    
    
    static func viewcontroller() -> CheckBalanceViewController {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "CheckBalanceViewController") as! CheckBalanceViewController
        return vc
    }
    
    @IBAction func clickBtnBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let points = userDefaults.value(forKey: "purchasedPoints") {
//            let alert = UIAlertController(title: "You have \(points) points, if you want to increase your points so then purchase it", message: "", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "Ok", style: .default) { (ok) in
//
//            }
//            alert.addAction(okAction)
//            self.present(alert, animated: true, completion: nil)
            totalPointLbl.text = "\(points)"
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let points = userDefaults.value(forKey: "purchasedPoints") {
//            let alert = UIAlertController(title: "You have \(points) points, if you want to increase your points so then purchase it", message: "", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "Ok", style: .default) { (ok) in
//                
//            }
//            alert.addAction(okAction)
//            self.present(alert, animated: true, completion: nil)
            totalPointLbl.text = "\(points)"
        }
    }
    
    @IBAction func clickBtnAddPoints(_ sender: UIButton) {
        
        if let points = userDefaults.value(forKey: "purchasedPoints") {
            let alert = UIAlertController(title: "You have already \(points) points, if you purchase with $50.00 then you will have more 50 points, would you like to increase your points ? ", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Yes", style: .default) { (ok) in
                self.presentPassSheet()
            }
            let noAction = UIAlertAction(title: "No", style: .destructive) { (ok) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okAction)
            alert.addAction(noAction)
            self.present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "You have 0 points, if you purchase with $50.00 then you will have 50 points, would you like to purchase points ? ", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Yes", style: .default) { (ok) in
                self.presentPassSheet()
            }
            let noAction = UIAlertAction(title: "No", style: .destructive) { (ok) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okAction)
            alert.addAction(noAction)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func presentPassSheet() {
        let paymentItem = PKPaymentSummaryItem.init(label: "For Points", amount: 50.00, type: .final)
        let paymentNetworks = [PKPaymentNetwork.amex, .discover, .masterCard, .visa]
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
            let request = PKPaymentRequest()
                request.currencyCode = "USD" // 1
                request.countryCode = "US" // 2
                request.merchantIdentifier = "merchant.com.app.coachculture" // 3
                request.merchantCapabilities = PKMerchantCapability.capability3DS // 4
                request.supportedNetworks = paymentNetworks // 5
                request.paymentSummaryItems = [paymentItem] // 6
            guard let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) else {
                displayDefaultAlert(title: "Error", message: "Unable to present Apple Pay authorization.")
                return
            }
            paymentVC.delegate = self
            self.present(paymentVC, animated: true, completion: nil)

        } else {
            displayDefaultAlert(title: "Error", message: "Unable to make Apple Pay transaction.")
        }
    }

    func displayDefaultAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (ok) in
            self.countingPoints = self.countingPoints + 50
            self.userDefaults.set(self.countingPoints, forKey: "purchasedPoints")
            if let credits = self.userDefaults.value(forKey: "purchasedPoints") {
                self.totalPointLbl.text = "\(credits)"
            }
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension CheckBalanceViewController: PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        dismiss(animated: true) {
            
        }
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        dismiss(animated: true, completion: nil)
        displayDefaultAlert(title: "Success!", message: "The Apple Pay transaction was complete")
    }
    
}
