//
//  PaymentMethodViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 22/12/21.
//

import UIKit
import CarLensCollectionViewLayout
import Stripe
import CHIPageControl

class PaymentMethodViewController: BaseViewController {
    
    static func viewcontroller() -> PaymentMethodViewController {
        let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentMethodViewController") as! PaymentMethodViewController
        return vc
    }
    @IBOutlet weak var viewNoDataFound: UIView!
    @IBOutlet weak var viewManageSubscription: UIView!
    @IBOutlet weak var viewBalance: UIView!
    @IBOutlet weak var viewConfirmPayment: UIView!
    @IBOutlet weak var clvCard: UICollectionView!
    @IBOutlet weak var lblAccountBalance: UILabel!
    @IBOutlet weak var CHIPagerControl: CHIPageControlJaloro!
    
    var arrCards : Welcome?
    var arrDatam : [[String:Any]]?
    private var currentSelectedIndex = 0
    private var isFromInitialLoading = true
    var isFromLiveClass = false
    var fees = ""
    var recdCurrency = ""
    var didFinishPaymentBlock : ((_ transaction_id: String, _ status: Bool) -> Void)!
    var arrLoadedCellID = [Int]()
    var isPrefferedSelected = false
    var isDeleteSelected = false
    var isFromCellSelection = false
    var selectedIndexpath = IndexPath(row: 0, section: 0)
    var arrColour = [UIColor.random, UIColor.random, UIColor.random, UIColor.random, UIColor.random, UIColor.random, UIColor.random, UIColor.random, UIColor.random, UIColor.random, UIColor.random, UIColor.random, UIColor.random, UIColor.random, UIColor.random]
    var coachID = 0
    var coachClassID = 0
    var isForCoach = false
    var transectionID = "avc"
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        isPrefferedSelected = false
        isDeleteSelected = false
        if Reachability.isConnectedToNetwork() {
            callGetCardsAPI(isShowLoader: true)
        }
    }
    
    //MARK: -  methods
    func setUpUI() {
        self.manageViews(isFromLiveClass: self.isFromLiveClass)
        hideTabBar()
        let options = CarLensCollectionViewLayoutOptions(minimumSpacing: 20)
        clvCard.collectionViewLayout = CarLensCollectionViewLayout(options: options)
        clvCard.register(UINib(nibName: "PaymentCardItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PaymentCardItemCollectionViewCell")
        clvCard.delegate = self
        clvCard.dataSource = self
    }
    
    func manageViews(isFromLiveClass: Bool) {
        self.viewConfirmPayment.isHidden = !isFromLiveClass
        self.viewBalance.isHidden = isFromLiveClass
        self.viewManageSubscription.isHidden = isFromLiveClass
    }
    
    func initialSetupPageControl() {
        self.CHIPagerControl.progress = 0.0
        self.CHIPagerControl.elementHeight = 3.0
        self.CHIPagerControl.elementWidth = 16.0
        self.CHIPagerControl.numberOfPages = self.arrCards?.data.count ?? 0
        self.CHIPagerControl.radius = 1
        self.CHIPagerControl.tintColor = hexStringToUIColor(hex: "#B2ADAD")
        self.CHIPagerControl.currentPageTintColor = hexStringToUIColor(hex: "#4694F9")
        self.CHIPagerControl.padding = 6
    }
    
    //MARK: - API CALL
    
    func callGetCardsAPI(isShowLoader: Bool) {
        if isShowLoader {
            showLoader()
        }
                
        let apiUrl = "\(STRIPE_API.payment_card_list)/\(AppPrefsManager.sharedInstance.getUserData().stripe_customer_id)/sources" //"\(STRIPE_API.payment_methods)?\(StripeParams.Cards.customer)=\(AppPrefsManager.sharedInstance.getUserData().stripe_customer_id)&\(StripeParams.Cards.type)=card"
        
        _ =  ApiCallManager.requestApiStripe(method: .get, urlString: apiUrl, parameters: nil, headers: nil) { responseObj, statusCode in
            self.hideLoader()
            if statusCode == RESPONSE_CODE.SUCCESS {
                if let arrayData = responseObj["data"] as? [Any] {
                    let arrData = responseObj
                    self.arrCards = Welcome.init(responseObj: arrData)
                    
//                    let dataObj = responseObj["data"]
//                    self.arrDatam.append(Datum(responseObj: dataObj as! [String : Any]))
                    
                    if let json = responseObj as? [String:Any], // <- Swift Dictionary
                       let results = json["data"] as? [[String:Any]]  { // <- Swift Array

                        self.arrDatam = results
                    }
                    
                    if arrayData.count > 0 {
                        self.viewNoDataFound.isHidden = true
                        self.initialSetupPageControl()
                        DispatchQueue.main.async {
                            self.clvCard.reloadData()
                            var arrIndexPaths: [IndexPath] = []
                            for index in 0..<(self.arrCards?.data.count ?? 0) {
//                                let randomColor = UIColor.random
//                                self.arrCards[index].bgColor = randomColor
                                arrIndexPaths.append(IndexPath(item: index, section: 0))
                            }
                            self.clvCard.reloadItems(at: arrIndexPaths)
                        }
                        self.viewConfirmPayment.isHidden = false
                    } else {
                        self.viewNoDataFound.isHidden = false
                        self.viewConfirmPayment.isHidden = true
                    }
                }
            } else {
                self.viewNoDataFound.isHidden = false
                self.viewConfirmPayment.isHidden = true
            }
        } failure: { (error) in
            self.viewNoDataFound.isHidden = false
            self.viewConfirmPayment.isHidden = true
            self.hideLoader()
            Utility.shared.showToast(error.localizedDescription)
            return true
        }
    }
    
    func callPaymentIntentsAPI(isShowLoader: Bool, customer: String) {
        if isShowLoader {
            showLoader()
        }
        var mainParams = [String:Any]()
//        var customer = ""
//        var id = ""
        
        /*if let tempcustomer = AppPrefsManager.sharedInstance.getSelectedPrefferedCardData()?.data.customer, !tempcustomer.isEmpty {
            customer = tempcustomer
        } else {
            customer = self.arrCards[0].data.customer
        }
        if let tempID = AppPrefsManager.sharedInstance.getSelectedPrefferedCardData()?.data.id, !tempID.isEmpty {
            id = tempID
        } else {
            id = self.arrCards[0].data.id
        }*/

        mainParams[StripeParams.PaymentIntents.amount] = String((Int(fees) ?? 0) * 100)
        mainParams[StripeParams.PaymentIntents.currency] = recdCurrency
        mainParams[StripeParams.PaymentIntents.customer] = customer
        if isForCoach {
            mainParams[StripeParams.PaymentIntents.description] = "coach subscribe"
        } else {
            mainParams[StripeParams.PaymentIntents.description] = "class subscribe"
        }
//        mainParams[StripeParams.PaymentIntents.confirm] = true
                    
        let apiUrl = STRIPE_API.payment_create_charge
        
        _ =  ApiCallManager.requestApiStripe(method: .post, urlString: apiUrl, parameters: mainParams, headers: nil) { responseObj, statusCode in
            if statusCode == RESPONSE_CODE.SUCCESS {
                if Reachability.isConnectedToNetwork() {
                    if let id = responseObj["id"] as? String {
                        self.callPaymentIntentsConfirmAPI(transactionId: id)
                    }
                }
            } else {
                self.hideLoader()
            }
        } failure: { (error) in
            self.hideLoader()
            Utility.shared.showToast(error.localizedDescription)
            return true
        }
    }
    
    func callPaymentIntentsConfirmAPI(transactionId: String) {
        if isForCoach {
            var mainParams = [String:Any]()
            
            mainParams[StripeParams.UserToCoach.coachId] = self.coachID
            mainParams[StripeParams.UserToCoach.transactionId] = transactionId
            let apiUrl = "\(API.ADD_USER_TO_COACH)"
            
            _ =  ApiCallManager.requestApi(method: .post, urlString: apiUrl, parameters: mainParams, headers: nil) { responseObj in
                self.hideLoader()
                CoachViseOnDemandClassViewController.isFromTransection = true
                self.popVC(animated: true)
            } failure: { (error) in
                self.hideLoader()
                Utility.shared.showToast(error.localizedDescription)
                return true
            }
        } else {
            var mainParams1 = [String:Any]()
            
            mainParams1[StripeParams.UserToCoachClass.coachClassId] = self.coachClassID
            mainParams1[StripeParams.UserToCoachClass.transactionId] = transactionId
            let apiUrl1 = "\(API.ADD_USER_TO_COACH_CLASS)"
            _ = ApiCallManager.requestApi(method: .post, urlString: apiUrl1, parameters: mainParams1, headers: nil) { responseObj in
                self.hideLoader()
                DispatchQueue.main.async {
                    LiveClassDetailsViewController.isFromTransection = true
                    self.popVC(animated: true)
                }
                if let next_action = responseObj["coach_details"] as? [String:Any] {
                    if let redirect_to_url = next_action["coach_class_id"] as? Int {
                        let apiUrl = "\(API.COACH_CLASS_DETAILS)"
                        var param = [String:Any]()
                        param["id"] = redirect_to_url
                        
                        _ = ApiCallManager.requestApi(method: .post, urlString: apiUrl, parameters: param, headers: nil) { responseObj in
                            let coachClassData = responseObj["coach_class"] as? [String:Any]
                            if let finalURL = URL(string: coachClassData?["thumbnail_video"] as? String ?? "") {
                                self.redirectToWebView(webURL: finalURL, transaction_id: responseObj["transaction_id"] as? String ?? "")
                            }
                            
                        } failure: { (err) -> Bool in
                            self.hideLoader()
                            Utility.shared.showToast(err.localizedDescription)
                            return true
                        }
                    }
                } else {
                    self.hideLoader()
                }
            } failure: { (err) -> Bool in
                self.hideLoader()
                Utility.shared.showToast(err.localizedDescription)
                return true
            }
        }
    }
    
    func redirectToWebView(webURL: URL, transaction_id: String) {
        let nextVC = CommonWebViewVC.instantiate(fromAppStoryboard: .Payment)
        nextVC.transaction_id = transaction_id
        nextVC.didLoadPaymentURLBlock = { transaction_id, status in
            self.navigateToRoot()
            if self.didFinishPaymentBlock != nil {
                self.didFinishPaymentBlock(transaction_id, status)
            }
        }
        nextVC.webURL = webURL
        self.pushVC(To: nextVC, animated: true)
    }
    
    private func navigateToRoot() {
        if self.navigationController?.viewControllers.count ?? 0 > 0 {
            for controller in self.navigationController!.viewControllers {
                if controller.isKind(of: LiveClassDetailsViewController.self) || controller.isKind(of: CoachViseOnDemandClassViewController.self) {
                    self.navigationController?.popToViewController(controller, animated: true)
                    break
                }
            }
        }
    }

    //MARK: - CLICK EVENTS
    
    @IBAction func btnConfirmPaymentClick( _ sender : UIButton) {
        if Reachability.isConnectedToNetwork() {
            callPaymentIntentsAPI(isShowLoader: true, customer: arrDatam?[sender.tag]["customer"] as? String ?? "")
        }
    }
    
    @IBAction func clickTobtnAddPaymentMethod( _ sender : UIButton) {
        let vc = AddPaymentMethodViewController.viewcontroller()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickTobtnManageSubscription( _ sender : UIButton) {
        let vc = ManageSubscriptionListViewController.viewcontroller()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clickTobtnAccountBalance( _ sender : UIButton) {
        let vc = AccountBalanceListViewController.viewcontroller()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}




// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension PaymentMethodViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        
        return self.arrDatam?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "PaymentCardItemCollectionViewCell", for: indexPath) as!  PaymentCardItemCollectionViewCell
        let model = arrDatam?[indexPath.row]
        
        cell.viewMainBG.backgroundColor = arrColour[indexPath.row]
        cell.viewPrefferedMethodMainBG.backgroundColor = arrColour[indexPath.row]
        cell.viewDeleteConfirmationMain.backgroundColor = arrColour[indexPath.row]
        
        if selectedIndexpath.row == indexPath.row {
            if isPrefferedSelected && isDeleteSelected {
                cell.viewDeleteConfirmationMain.isHidden = false
                cell.viewPrefferedMethodMainBG.isHidden = true
                cell.viewMainBG.isHidden = true
            } else if isPrefferedSelected {
                cell.viewPrefferedMethodMainBG.isHidden = false
                cell.viewDeleteConfirmationMain.isHidden = true
                cell.viewMainBG.isHidden = true
            } else {
                cell.viewDeleteConfirmationMain.isHidden = true
                cell.viewPrefferedMethodMainBG.isHidden = true
                cell.viewMainBG.isHidden = false
            }
        } else {
            cell.viewDeleteConfirmationMain.isHidden = true
            cell.viewPrefferedMethodMainBG.isHidden = true
            cell.viewMainBG.isHidden = false
        }
        
        let metadata = model?["metadata"] as? [String:Any] ?? [String:Any]()
        cell.lblCardHolderName.text = model?["name"] as? String ?? ""
        let exp_month = Int(model?["exp_month"] as? Int ?? 0)
        
        cell.lblValidThrough.text = "\(String(format: "%02d", exp_month))/" + "\(model?["exp_year"] as? Int ?? 0)".suffix(2)
        
        var hastrickCardNo = ""
        for _ in (metadata["card_number"] as! String).trimmingCharacters(in: .whitespacesAndNewlines).enumerated() {
            hastrickCardNo.append("*")
        }
        let subCardNo = hastrickCardNo.pairs.joined(separator: " ").dropLast(4)
        cell.lblCardNo.text = subCardNo.appending("\((model?["last4"] as? String) ?? "")")
        
        cell.btnSelectPreffered.tag = indexPath.row
        cell.btnSelectPreffered.removeTarget(self, action: #selector(btnSelectPrefferedClick(_:)), for: .touchUpInside)
        cell.btnSelectPreffered.addTarget(self, action: #selector(btnSelectPrefferedClick(_:)), for: .touchUpInside)
        
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.removeTarget(self, action: #selector(btnDeleteClick(_:)), for: .touchUpInside)
        cell.btnDelete.addTarget(self, action: #selector(btnDeleteClick(_:)), for: .touchUpInside)
        
        cell.btnYes.tag = indexPath.row
        cell.btnYes.removeTarget(self, action: #selector(btnYesClick(_:)), for: .touchUpInside)
        cell.btnYes.addTarget(self, action: #selector(btnYesClick(_:)), for: .touchUpInside)
        
        cell.btnNo.tag = indexPath.row
        cell.btnNo.removeTarget(self, action: #selector(btnNoClick(_:)), for: .touchUpInside)
        cell.btnNo.addTarget(self, action: #selector(btnNoClick(_:)), for: .touchUpInside)
        let cardBrand = STPCardValidator.brand(forNumber: metadata["card_number"] as! String)
        let cardImage = STPImageLibrary.cardBrandImage(for: cardBrand)
        cell.imgCardType.image = cardImage
        
        cell.layoutIfNeeded()
        return cell
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        isFromInitialLoading = false
        DispatchQueue.main.async {
            guard scrollView == self.clvCard else {
                return
            }
            
            targetContentOffset.pointee = scrollView.contentOffset
            
            let flowLayout = self.clvCard.collectionViewLayout as! CarLensCollectionViewLayout
            let cellWidthIncludingSpacing = flowLayout.itemSize.width + flowLayout.minimumLineSpacing
            let offset = targetContentOffset.pointee
            let horizontalVelocity = velocity.x
                        
            switch horizontalVelocity {
            // On swiping
            case _ where horizontalVelocity > 0 :
                self.currentSelectedIndex += 1
            case _ where horizontalVelocity < 0:
                self.currentSelectedIndex -= 1
                
            // On dragging
            case _ where horizontalVelocity == 0:
                let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
                let roundedIndex = round(index)
                
                self.currentSelectedIndex = Int(roundedIndex)
            default:
                print("Incorrect velocity for collection view")
            }
            
            let safeIndex = max(0, min(self.currentSelectedIndex, (self.arrCards?.data.count ?? 0) - 1))
            let selectedIndexPath = IndexPath(row: safeIndex, section: 0)
                   
            self.currentSelectedIndex = selectedIndexPath.row
            self.CHIPagerControl.set(progress: safeIndex, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isFromCellSelection = true
        selectedIndexpath = indexPath
        if isPrefferedSelected && isDeleteSelected {
            isPrefferedSelected = false
            isDeleteSelected = false
        } else if !isPrefferedSelected {
            isPrefferedSelected = !isPrefferedSelected
        } else {
            isPrefferedSelected = false
            isDeleteSelected = false
        }
        DispatchQueue.main.async {
            self.clvCard.reloadItems(at: [indexPath])
        }
    }

    func callPaymentMethodsDetachAPI(_ dic: [String:Any]) {
        showLoader()
        let apiUrl = "\(STRIPE_API.payment_card_delete)/\(dic["customer"] ?? "")/sources/\(dic["id"] ?? "")"
        
        _ =  ApiCallManager.requestApiStripe(method: .delete, urlString: apiUrl, parameters: nil, headers: nil) { responseObj, statusCode in
            if statusCode == RESPONSE_CODE.SUCCESS {
                self.callGetCardsAPI(isShowLoader: false)
            } else {
                self.hideLoader()
            }
        } failure: { (error) in
            self.hideLoader()
            Utility.shared.showToast(error.localizedDescription)
            return true
        }
    }

    func callSelectedPreferrdMethod(_ selectedPath: Int) {
        showLoader()
        let data = arrDatam?[selectedPath]
        let apiUrl = "\(STRIPE_API.payment_update_customer)/\(data?["customer"] ?? "")"
        
        var param = [String:Any]()
        param["invoice_settings[default_payment_method]"] = data?["id"]
        param["default_card"] = data?["id"]
        
        _ =  ApiCallManager.requestApiStripe(method: .post, urlString: apiUrl, parameters: param, headers: nil) { responseObj, statusCode in
            if statusCode == RESPONSE_CODE.SUCCESS {
                self.hideLoader()
                Utility().showToast("Card set as a Preferred Method")
            } else {
                self.hideLoader()
            }
        } failure: { (error) in
            self.hideLoader()
            Utility.shared.showToast(error.localizedDescription)
            return true
        }
    }
    
    @IBAction func btnSelectPrefferedClick( _ sender : UIButton) {
        if Reachability.isConnectedToNetwork() {
            self.callSelectedPreferrdMethod(sender.tag)
        }
        isPrefferedSelected = false
        isDeleteSelected = false
        DispatchQueue.main.async {
            self.clvCard.reloadItems(at: [IndexPath(item: sender.tag, section: 0)])
        }
    }

    @IBAction func btnYesClick( _ sender : UIButton) {
//        let model = arrCards?.data[sender.tag]
        isPrefferedSelected = false
        isDeleteSelected = false
        if Reachability.isConnectedToNetwork() {
            self.callPaymentMethodsDetachAPI(arrDatam?[sender.tag] ?? [String:Any]())
        }
    }
    
    @IBAction func btnNoClick( _ sender : UIButton) {
        isPrefferedSelected = false
        isDeleteSelected = false
        DispatchQueue.main.async {
            self.clvCard.reloadItems(at: [IndexPath(item: sender.tag, section: 0)])
        }
    }

    @IBAction func btnDeleteClick( _ sender : UIButton) {
        isPrefferedSelected = true
        isDeleteSelected = true
        DispatchQueue.main.async {
            self.clvCard.reloadItems(at: [IndexPath(item: sender.tag, section: 0)])
        }
    }
}

extension String {
    var pairs: [String] {
        var result: [String] = []
        let chars = Array(self)
        for index in stride(from: 0, to: chars.count, by: 4){
            result.append(String(chars[index..<min(index+4, chars.count)]))
        }
        return result
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}
