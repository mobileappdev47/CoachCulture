//
//  AccountBalanceListViewController.swift
//  CoachCulture
//
//  Created by AnjaliMendpara on 23/12/21.
//

import UIKit

class AccountBalanceListViewController: BaseViewController {
    
    static func viewcontroller() -> AccountBalanceListViewController {
        let vc = UIStoryboard(name: "Payment", bundle: nil).instantiateViewController(withIdentifier: "AccountBalanceListViewController") as! AccountBalanceListViewController
        return vc
    }
    
    @IBOutlet weak var viewLastTransaction: UIView!
    @IBOutlet weak var tblLastTransaction: UITableView!
    
    @IBOutlet weak var lblBalance: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    // MARK: - Methods
    func setUpUI() {
        viewLastTransaction.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tblLastTransaction.register(UINib(nibName: "TransactionItemTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionItemTableViewCell")
        tblLastTransaction.delegate = self
        tblLastTransaction.dataSource = self
        
    }
    
    @IBAction func onClkTransfre(_ sender: UIButton) {
        let vc = PaymentMethodViewController.viewcontroller()
        vc.isFromTransfer = true
        self.pushVC(To: vc, animated: true)
    }
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension AccountBalanceListViewController : UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionItemTableViewCell", for: indexPath) as! TransactionItemTableViewCell
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
