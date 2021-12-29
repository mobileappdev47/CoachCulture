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
    

    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // .
        setUpUI()
    }
    //MARK: -  methods
    func setUpUI() {
        hideTabBar()
        clvCard.register(UINib(nibName: "PaymentCardItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PaymentCardItemCollectionViewCell")
        clvCard.delegate = self
        clvCard.dataSource = self
        clvCard.reloadData()
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
        
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "PaymentCardItemCollectionViewCell", for: indexPath) as!  PaymentCardItemCollectionViewCell
        
        return cell
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        return CGSize(width: collectionView.frame.width - 30, height: 186)
    }
    
    
}

