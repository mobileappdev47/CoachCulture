//
//  CheckBalanceViewController.swift
//  CoachCulture
//
//  Created by mac on 13/08/1944 Saka.
//

import UIKit
import PassKit

class LastHistoryCell: UITableViewCell {
    
}

class Trans {
    
    var id = 0
    var status = ""
    var point = 0
    
    init(data: [String:Any]) {
        id = data["id"] as! Int
        status = data["status"] as! String
        point = data["point"] as! Int
    }
}



class CheckBalanceViewController: UIViewController {

    @IBOutlet weak var clickBtnBack: UIButton!
    @IBOutlet weak var totalPointLbl: UILabel!
    @IBOutlet weak var addPointsBtn: UIButton!
    @IBOutlet weak var enterPointsTxtField: UITextField!
    @IBOutlet weak var icWrongImg: UIImageView!
    @IBOutlet weak var btnOne: UIButton!
    @IBOutlet weak var btnTwo: UIButton!
    @IBOutlet weak var btnThree: UIButton!
    @IBOutlet weak var lastHistoryTblView: UITableView!
    
    var btnValuePoints = 0
    
    var totalPoint = 0
    var enteredPointsString = ""
    var enteredPointsInInt = 0
    
    var pointHistoryArr = [Trans]()
    
    //    let userDefaults = UserDefaults.standard
    
    static func viewcontroller() -> CheckBalanceViewController {
        let vc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "CheckBalanceViewController") as! CheckBalanceViewController
        return vc
    }
    
    @IBAction func clickBtnBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lastHistoryTblView.register(UINib(nibName: "LastTransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "LastTransactionTableViewCell")
        getPointHistoryApi()
        
//        if let points = userDefaults.value(forKey: "purchasedPoints") {
//            countingPoints = points as! Int
//            totalPointLbl.text = "\(points)"
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getPointHistoryApi()
//        if let points = userDefaults.value(forKey: "purchasedPoints") {
//            countingPoints = points as! Int
//            totalPointLbl.text = "\(points)"
//        }
    }
    
    
    
    //MARK:- Point Related Api
    
    func addPointsApi(paymentStatus: Int) {

        let urlString = "\(API.BASE_URL)api/point/add-point"
        let parameter = ["point": btnValuePoints,
                         "status": paymentStatus ] as [String: Any]
        let header = ["Authorization": "Bearer \(AppPrefsManager.sharedInstance.getUserAccessToken())", ]

        _ =  ApiCallManager.requestApi(method: .post, urlString: urlString, parameters: parameter, headers: header) { responseObj in

            //            let responseModel = ResponseDataModel(responseObj: responseObj)

            let message = responseObj["message"] as? String
            
            DispatchQueue.main.async {
                self.showToast(message: message!, seconds: 3.5)
            }

        } failure: { (error) -> Bool in
            return true
        }
        getPointHistoryApi()
    }
    
    func getPointHistoryApi() {
        
        let urlString = "\(API.BASE_URL)api/point/get-point-history"
        
        let parameter = ["page_no": 1,
                         "per_page": 5] as [String: Any]
        let header = ["Authorization": "Bearer \(AppPrefsManager.sharedInstance.getUserAccessToken())", ]
        
        _ =  ApiCallManager.requestApi(method: .post, urlString: urlString, parameters: parameter, headers: header) { responseObj in
            
            //            let responseModel = ResponseDataModel(responseObj: responseObj)
            
            let data = responseObj["data"] as? [String: Any]
            let pointInfo = data?["point_info"] as? [String: Any]
            let totalPoints = pointInfo?["total"]

            if let pointHistory = data?["point_history"] as? [[String : Any]] {
                for aDataItem in pointHistory {
                    self.pointHistoryArr.append(Trans(data: aDataItem))
                }
            }
            
            DispatchQueue.main.async {
                self.totalPointLbl.text = "\(totalPoints!)"
                self.lastHistoryTblView.reloadData()
            }
            
        } failure: { (error) -> Bool in
            return true
        }
    }
    
    @IBAction func didTapPointsQueryPopUp(_ sender: UIButton) {
        let vc = PopupViewController.viewcontroller()
        vc.isHide = true
        vc.message = """
                            How to purchase points ?

                            Users will pay a points to access class and get points at a different rate which according to your entered points.

                            For every “On Demand” and “Live” Class, you will be able to pay a different points for users who subscribed and users who did not subscribe.

                            you have selected 25 point so you have to pay $25, selected 50 then have to pay $50 and selected 100 then have to pay $100.
                            """
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func didSelectPointBtn(_ sender: UIButton) {
        print("tap")
        icWrongImg.isHidden = true
        switch sender {
        case btnOne :
            btnOne.backgroundColor = UIColor(named: "tabbarColor")
            
            btnValuePoints = 25
            
            btnTwo.backgroundColor = UIColor(named: "themeColor")
            btnThree.backgroundColor = UIColor(named: "themeColor")
        case btnTwo :
            btnTwo.backgroundColor = UIColor(named: "tabbarColor")
            
            btnValuePoints = 50
            
            btnOne.backgroundColor = UIColor(named: "themeColor")
            btnThree.backgroundColor = UIColor(named: "themeColor")
        case btnThree :
            btnThree.backgroundColor = UIColor(named: "tabbarColor")
            
            btnValuePoints = 100
            
            btnOne.backgroundColor = UIColor(named: "themeColor")
            btnTwo.backgroundColor = UIColor(named: "themeColor")
        default:
            break
        }
    }
    
    
    @IBAction func clickBtnAddPoints(_ sender: UIButton) {
        if btnValuePoints != 0 {
            if totalPoint != 0 {
                pointsDescribeAlert(title: "You have already \(totalPoint) points, you have selected \(btnValuePoints) points or you have to purchase with $\(btnValuePoints) would you like to purchase point? ", message: "")
            } else {
                pointsDescribeAlert(title: "You have 0 points, you have selected \(btnValuePoints) points or you have to purchase with $\(btnValuePoints) would you like to purchase point ? ", message: "")
            }
        } else {
            icWrongImg.isHidden = false
        }
    }
    
    func pointsDescribeAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
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
    
    func presentPassSheet() {
            
        let paymentItem = PKPaymentSummaryItem.init(label: "For \(btnValuePoints) Points", amount: NSDecimalNumber(value: btnValuePoints), type: .final)
        let paymentNetworks = [PKPaymentNetwork.amex, .discover, .masterCard, .visa]
        let canMakePayment = PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks)
        if canMakePayment {
            let request = PKPaymentRequest()
            request.currencyCode = "USD" // 1
            request.countryCode = "US" // 2
            request.merchantIdentifier = "merchant.com.app.coachculture" // 3
            request.merchantCapabilities = PKMerchantCapability.capability3DS // 4
            request.supportedNetworks = paymentNetworks // 5
            request.paymentSummaryItems = [paymentItem] // 6
            guard let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) else {
                displayDefaultErrorAlert(title: "Error", message: "Unable to present Apple Pay authorization.")
                return
            }
            //            canMakePayment = PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks)
            paymentVC.delegate = self
            self.present(paymentVC, animated: true, completion: nil)
        } else {
            displayDefaultErrorAlert(title: "Error", message: "Unable to make Apple Pay transaction.")
        }
        
    }
    
    func displayDefaultErrorAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (ok) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

    func displayDefaultAlert(title: String?, message: String?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (ok) in
            self.addPointsApi(paymentStatus: 1 )
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

extension CheckBalanceViewController: PKPaymentAuthorizationViewControllerDelegate {
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        dismiss(animated: true, completion: nil)
        displayDefaultAlert(title: "Success!", message: "The Apple Pay transaction was complete")
    }
    
}

extension CheckBalanceViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pointHistoryArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = lastHistoryTblView.dequeueReusableCell(withIdentifier: "LastTransactionTableViewCell") as! LastTransactionTableViewCell
        let Objar = pointHistoryArr[indexPath.row]
        cell.pointsLbl.text = "\(Objar.point)"
        cell.statusLbl.text = Objar.status
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
