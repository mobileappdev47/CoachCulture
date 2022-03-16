//
//  PaymentMethodViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 22/12/21.
//

import UIKit
import CarLensCollectionViewLayout

class PaymentMethodViewController: BaseViewController {
    
    static func viewcontroller() -> PaymentMethodViewController {
        let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "PaymentMethodViewController") as! PaymentMethodViewController
        return vc
    }
    
    @IBOutlet weak var clvCard: UICollectionView!
    @IBOutlet weak var lblAccountBalance: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!

    var arrCards = [StripeCardsDataModel]()
    var selectedCellIndex : Int?
    private var currentSelectedIndex = 0
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
        let options = CarLensCollectionViewLayoutOptions(minimumSpacing: 20)
        clvCard.collectionViewLayout = CarLensCollectionViewLayout(options: options)
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
        
        selectedCellIndex = indexPath.row
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
        
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
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
            self.pageControl.currentPage = safeIndex
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
