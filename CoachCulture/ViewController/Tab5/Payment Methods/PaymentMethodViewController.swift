//
//  PaymentMethodViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 22/12/21.
//

import UIKit


class PaymentMethodViewController: BaseViewController {
    
    static func viewcontroller() -> PaymentMethodViewController {
        let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentMethodViewController") as! PaymentMethodViewController
        return vc
    }
    
    @IBOutlet weak var clvCard: UICollectionView!
    @IBOutlet weak var lblAccountBalance: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!

    var arrCards = [StripeCardsDataModel]()

    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Reachability.isConnectedToNetwork() {
            callGetCardsAPI()
        }
    }
    
    //MARK: -  methods
    func setUpUI() {
        hideTabBar()
        clvCard.register(UINib(nibName: "PaymentCardItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PaymentCardItemCollectionViewCell")
        clvCard.delegate = self
        clvCard.dataSource = self
    }
    
    //MARK: - API CALL
    
    func callGetCardsAPI() {
        showLoader()
                
        let apiUrl = "\(STRIPE_API.payment_methods)?\(StripeParams.Cards.customer)=\(AppPrefsManager.sharedInstance.getUserData().stripe_customer_id)&\(StripeParams.Cards.type)=card"
        
        _ =  ApiCallManager.requestApiStripe(method: .get, urlString: apiUrl, parameters: nil, headers: nil) { responseObj, statusCode in
            self.hideLoader()
            if statusCode == RESPONSE_CODE.SUCCESS {
                if let arrData = responseObj["data"] as? [Any] {
                    self.arrCards.removeAll()
                    self.arrCards = StripeCardsDataModel.getData(data: arrData)
                    if self.arrCards.count > 0 {
                        self.pageControl.currentPage = 0
                        self.pageControl.numberOfPages = self.arrCards.count
                        DispatchQueue.main.async {
                            self.clvCard.reloadData()
                        }
                    }
                }
            }
        } failure: { (error) in
            self.hideLoader()
            Utility.shared.showToast(error.localizedDescription)
            return true
        }
    }
    //MARK: - CLICK EVENTS
    
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
        cell.lblCardHolderName.text = model.metadata.holder_name
        cell.lblValidThrough.text = "\(model.card.exp_month)/\(model.card.exp_year.suffix(2))"
        
        var hastrickCardNo = ""
        for _ in model.metadata.card_number.trimmingCharacters(in: .whitespacesAndNewlines).enumerated() {
            hastrickCardNo.append("*")
        }
        
        let subCardNo = hastrickCardNo.pairs.joined(separator: " ").dropLast(4) //1234 5678 9012 3456 789
        
        cell.lblCardNo.text = subCardNo.appending("\(model.card.last4)")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 30, height: 186)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let indexpath = clvCard.indexPathsForVisibleItems.first {
            pageControl.currentPage = indexpath.row
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
