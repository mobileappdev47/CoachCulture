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
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var CHIPagerControl: CHIPageControlJaloro!
    
    var arrCards = [StripeCardsDataModel]()
    private var currentSelectedIndex = 0
    private var isFromInitialLoading = true
    var isFromLiveClass = false
    var fees = ""
    var recdCurrency = ""
    var didFinishPaymentBlock : ((_ transaction_id: String, _ status: Bool) -> Void)!
    var arrLoadedCellID = [Int]()

    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    //MARK: - API CALL
    
    func callGetCardsAPI(isShowLoader: Bool) {
        if isShowLoader {
            showLoader()
        }
                
        let apiUrl = "\(STRIPE_API.payment_methods)?\(StripeParams.Cards.customer)=\(AppPrefsManager.sharedInstance.getUserData().stripe_customer_id)&\(StripeParams.Cards.type)=card"
        
        _ =  ApiCallManager.requestApiStripe(method: .get, urlString: apiUrl, parameters: nil, headers: nil) { responseObj, statusCode in
            self.hideLoader()
            if statusCode == RESPONSE_CODE.SUCCESS {
                if let arrData = responseObj["data"] as? [Any] {
                    self.arrCards.removeAll()
                    self.arrCards = StripeCardsDataModel.getData(data: arrData)
                    if self.arrCards.count > 0 {
                        self.viewNoDataFound.isHidden = true
                        //self.pageControl.currentPage = 0
                        //self.pageControl.numberOfPages = self.arrCards.count
                        
                        self.CHIPagerControl.progress = 0.0
                        self.CHIPagerControl.elementHeight = 3.0
                        self.CHIPagerControl.elementWidth = 16.0
                        self.CHIPagerControl.numberOfPages = self.arrCards.count
                        self.CHIPagerControl.radius = 1
                        self.CHIPagerControl.tintColor = hexStringToUIColor(hex: "#B2ADAD")
                        self.CHIPagerControl.currentPageTintColor = hexStringToUIColor(hex: "#4694F9")
                        self.CHIPagerControl.padding = 6

                        
                        DispatchQueue.main.async {
                            self.clvCard.reloadData()
                            var arrIndexPaths: [IndexPath] = []
                            for index in 0..<self.arrCards.count {
                                let randomColor = UIColor.random
                                self.arrCards[index].bgColor = randomColor
                                arrIndexPaths.append(IndexPath(item: index, section: 0))
                            }
                            self.clvCard.reloadItems(at: arrIndexPaths)
                        }
                    } else {
                        self.viewNoDataFound.isHidden = false
                    }
                }
            } else {
                self.viewNoDataFound.isHidden = false
            }
        } failure: { (error) in
            self.viewNoDataFound.isHidden = false
            self.hideLoader()
            Utility.shared.showToast(error.localizedDescription)
            return true
        }
    }
    
    func callPaymentIntentsAPI(isShowLoader: Bool) {
        if isShowLoader {
            showLoader()
        }
        var mainParams = [String:Any]()
        var customer = ""
        var id = ""
        
        if let tempcustomer = AppPrefsManager.sharedInstance.getSelectedPrefferedCardData()?.customer, !tempcustomer.isEmpty {
            customer = tempcustomer
        } else {
            customer = self.arrCards[0].customer
        }
        if let tempID = AppPrefsManager.sharedInstance.getSelectedPrefferedCardData()?.id, !tempID.isEmpty {
            id = tempID
        } else {
            id = self.arrCards[0].id
        }

        mainParams[StripeParams.PaymentIntents.amount] = fees
        mainParams[StripeParams.PaymentIntents.currency] = recdCurrency
        mainParams[StripeParams.PaymentIntents.customer] = customer
        mainParams[StripeParams.PaymentIntents.payment_method] = id
        mainParams[StripeParams.PaymentIntents.confirm] = true
                
        let apiUrl = STRIPE_API.payment_intents
        
        _ =  ApiCallManager.requestApiStripe(method: .post, urlString: apiUrl, parameters: mainParams, headers: nil) { responseObj, statusCode in
            if statusCode == RESPONSE_CODE.SUCCESS {
                if Reachability.isConnectedToNetwork() {
                    if let id = responseObj["id"] as? String {
                        if let payment_method = responseObj["payment_method"] as? String {
                            self.callPaymentIntentsConfirmAPI(intent: id, payment_method: payment_method)
                        }
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
    
    func callPaymentIntentsConfirmAPI(intent: String, payment_method: String) {
        var mainParams = [String:Any]()

        mainParams[StripeParams.PaymentIntentsConfirm.return_url] = StripeConstant.CallBack_URL.rawValue
        mainParams[StripeParams.PaymentIntentsConfirm.payment_method] = payment_method
                
        let apiUrl = "\(STRIPE_API.payment_intents)/\(intent)/confirm"
        
        _ =  ApiCallManager.requestApiStripe(method: .post, urlString: apiUrl, parameters: mainParams, headers: nil) { responseObj, statusCode in
            if statusCode == RESPONSE_CODE.SUCCESS {
                self.hideLoader()
                if let next_action = responseObj["next_action"] as? [String:Any] {
                    if let redirect_to_url = next_action["redirect_to_url"] as? [String:Any] {
                        if let urlStr = redirect_to_url["url"] as? String {
                            if let finalURL = URL(string: urlStr) {
                                if let recdID = responseObj["id"] as? String {
                                    self.redirectToWebView(webURL: finalURL, transaction_id: recdID)
                                }
                            }
                        }
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
    
    func redirectToWebView(webURL: URL, transaction_id: String) {
        let nextVC = CommonWebViewVC.instantiate(fromAppStoryboard: .Payment)
        nextVC.transaction_id = transaction_id
        nextVC.didLoadPaymentURLBlock = { transaction_id, status in
            if self.didFinishPaymentBlock != nil {
                self.didFinishPaymentBlock(transaction_id, status)
            }
        }
        nextVC.webURL = webURL
        self.pushVC(To: nextVC, animated: true)
    }
    
    //MARK: - CLICK EVENTS
    
    @IBAction func btnConfirmPaymentClick( _ sender : UIButton) {
        if Reachability.isConnectedToNetwork() {
            callPaymentIntentsAPI(isShowLoader: true)
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
        
        return self.arrCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "PaymentCardItemCollectionViewCell", for: indexPath) as!  PaymentCardItemCollectionViewCell
        let model = arrCards[indexPath.row]
        
        cell.viewMainBG.backgroundColor = model.bgColor
        cell.viewPrefferedMethodMainBG.backgroundColor = model.bgColor
        cell.viewDeleteConfirmationMain.backgroundColor = model.bgColor

        if model.isPrefferedSelected && model.isDeleteSelected {
            cell.viewDeleteConfirmationMain.isHidden = false
            cell.viewPrefferedMethodMainBG.isHidden = true
            cell.viewMainBG.isHidden = true
        } else if model.isPrefferedSelected {
            cell.viewPrefferedMethodMainBG.isHidden = false
            cell.viewDeleteConfirmationMain.isHidden = true
            cell.viewMainBG.isHidden = true
        } else {
            cell.viewDeleteConfirmationMain.isHidden = true
            cell.viewPrefferedMethodMainBG.isHidden = true
            cell.viewMainBG.isHidden = false
        }
        
        cell.lblCardHolderName.text = model.metadata.holder_name
        let exp_month = Int(model.card.exp_month) ?? 0
        
        cell.lblValidThrough.text = "\(String(format: "%02d", exp_month))/\(model.card.exp_year.suffix(2))"
        
        var hastrickCardNo = ""
        for _ in model.metadata.card_number.trimmingCharacters(in: .whitespacesAndNewlines).enumerated() {
            hastrickCardNo.append("*")
        }
        let subCardNo = hastrickCardNo.pairs.joined(separator: " ").dropLast(4)
        cell.lblCardNo.text = subCardNo.appending("\(model.card.last4)")
        
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

        let cardBrand = STPCardValidator.brand(forNumber: model.metadata.card_number)
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
            
            let safeIndex = max(0, min(self.currentSelectedIndex, self.arrCards.count - 1))
            let selectedIndexPath = IndexPath(row: safeIndex, section: 0)
                   
            self.currentSelectedIndex = selectedIndexPath.row
            self.CHIPagerControl.set(progress: safeIndex, animated: true)
            //self.pageControl.currentPage = safeIndex
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = arrCards[indexPath.row]
        model.isFromCellSelection = true
        if model.isPrefferedSelected && model.isDeleteSelected {
            model.isPrefferedSelected = false
            model.isDeleteSelected = false
        } else if !model.isPrefferedSelected {
            model.isPrefferedSelected = !model.isPrefferedSelected
        } else {
            model.isPrefferedSelected = false
            model.isDeleteSelected = false
        }
        DispatchQueue.main.async {
            self.clvCard.reloadItems(at: [indexPath])
        }
    }

    func callPaymentMethodsDetachAPI(model: StripeCardsDataModel?) {
        showLoader()
        let apiUrl = "\(STRIPE_API.payment_methods)/\(model?.id ?? AppPrefsManager.sharedInstance.getUserData().stripe_customer_id)/detach"
        
        _ =  ApiCallManager.requestApiStripe(method: .post, urlString: apiUrl, parameters: nil, headers: nil) { responseObj, statusCode in
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

    @IBAction func btnSelectPrefferedClick( _ sender : UIButton) {
        let model = arrCards[sender.tag]
        if let cardDict = StripeCardsDataModel.getCardDictionary(from: model) {
            AppPrefsManager.sharedInstance.saveSelectedPrefferedCardData(userData: cardDict)
        }
        model.isPrefferedSelected = false
        model.isDeleteSelected = false
        DispatchQueue.main.async {
            self.clvCard.reloadItems(at: [IndexPath(item: sender.tag, section: 0)])
        }
    }

    @IBAction func btnYesClick( _ sender : UIButton) {
        let model = arrCards[sender.tag]
        if Reachability.isConnectedToNetwork() {
            self.callPaymentMethodsDetachAPI(model: model)
        }
    }
    
    @IBAction func btnNoClick( _ sender : UIButton) {
        let model = arrCards[sender.tag]
        model.isPrefferedSelected = false
        model.isDeleteSelected = false
        DispatchQueue.main.async {
            self.clvCard.reloadItems(at: [IndexPath(item: sender.tag, section: 0)])
        }
    }

    @IBAction func btnDeleteClick( _ sender : UIButton) {
        let model = arrCards[sender.tag]
//        model.isPrefferedSelected = false
        model.isDeleteSelected = !model.isDeleteSelected
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
